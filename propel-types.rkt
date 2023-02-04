#lang racket

(require "form-db.rkt"
         "propel-models.rkt"
         "propel-names.rkt"
         "propel-syntax.rkt"
         "scope.rkt"
         )

(provide resolve-types)

(define (resolve-types form-db stx)
  (resolve-types/form form-db (make-module-scope -100) stx))

; in:   AST
; out:  (type . subtree)
;; Note that we only return trees of types which have no useful interpretation without having the original expression
(define (resolve-types/form form-db current-scope stx)
  (define rec (curry resolve-types/form form-db current-scope))     ; recurse
  ; (printf "resolve-types ~a\n" stx)
  ;stx

  ;; first try to look up a definition in the form database, and use that
  (define form-def (get-form-def-for-stx form-db stx))
  (define form-handler (if form-def (hash-ref (form-def-phases form-def) 'types #f) #f))

  (if form-handler
    (apply-handler form-db form-def form-handler current-scope stx)

   (match (syntax-e stx)
     [(list (? is-#%begin? t) stmts ..1)
      (let ([sub-trees (map rec stmts)])
        (cons (car (last sub-trees)) sub-trees)
        )]
     [(list (? is-#%begin? t))
      (cons type-V '())]
     [(list (? is-#%app? t) callee args ...)
      (begin
        (define callee-tt (rec callee))
        (define arg-tts (map rec args))
        (check-function-args stx (function-type-arg-types (car callee-tt)) (map car arg-tts))

        ; (how to deal with overloaded functions...?)
        (define return-type (function-type-ret-type (car callee-tt)))

        ;; construct new, typed function call
        ;; this is a cons of the result type and a list with the type tree for the callee,
        ;; followed by all the arguments
        (cons return-type (cons callee-tt arg-tts))
        )
      ]
    ;; warning: *absolute dumpster fire ahead*
    [(list (? is-#%construct? t) type-stx args-stx ...)
     (match (syntax->datum type-stx)
       [`(#%array-type (#%builtin-type I) ,length)
        ;; TODO: validate length
        (cons (syntax->datum type-stx) (map rec args-stx))]
       ['(#%builtin-type V)
        (begin
          (unless (empty? args-stx)
            (raise-syntax-error #f
                                "expected 0 arguments when constructing Void"
                                stx))
          (cons type-V #f))]
       [_
        (raise-syntax-error #f
                            "only Void type can be currently constructed"
                            stx)])]
     [(list (? is-#%define-or-#%define-var? _) var-stx value)
      ;; recurse to value & insert type information
      (define value-tt (rec value))
      (define value-type (car value-tt))

      (match-define (list '#%scoped-var scope-id name) (syntax->datum var-stx))

      ;; TODO: should assert that scope-id matches that of the current scope, no?
      (scope-discover-variable-type! current-scope scope-id name value-type)
      (cons type-V value-tt)
      ]
     [(list (? is-#%defun? t) var-stx args-stx ret-stx body-stx)
      (define func-scope
        (scope -1 current-scope
               (add1 (scope-level current-scope))
               (make-hash)
               (make-hash)
               (make-hash)))
      ;; insert arguments
      (for ([arg-stx (syntax-e args-stx)])
        (match-define `((#%scoped-var ,scope-id ,name) ,type) (syntax->datum arg-stx))
        (scope-discover-variable-type! func-scope scope-id name type)
        )

      (define arg-types (map (lambda (arg-stx) (begin
        (match-define (list name-stx type-stx) (syntax-e arg-stx))
        (syntax->datum type-stx)
        )) (syntax-e args-stx)))

      (define ret-type (syntax->datum ret-stx))

      (match-define `(#%scoped-var ,scope-id ,name) (syntax->datum var-stx))
      (scope-discover-variable-type! current-scope scope-id name
        (function-type arg-types ret-type))

      (define body-tt (resolve-types/form form-db func-scope body-stx))
      ;(list t name-stx args-stx ret-stx body-stx)

      (define body-t (car body-tt))
      (unless (equal? body-t ret-type)
              (raise-syntax-error #f (format "defun: ~a: body expression type (~a) does not match declared return type (~a)" name body-t ret-type) stx))

      (cons type-V body-tt)
      ]
     #;[(list (? is-#%dot? t) obj field)
        ; 1. recurse to obj
        ; 2. resolve field
        ]
     [(list (? is-#%deftype? t) name-stx definition-stx) (cons type-V #f)]
     [(list (? is-#%external-function? t) name-stx args-stx ret-stx header-stx)
      (define name (syntax-e name-stx))
      (define args (syntax->datum args-stx))
      (define ret (syntax->datum ret-stx))

      (cons (function-type (map cadr args) ret) #f)
      ]
     [(list (? is-#%if? t) expr then else)
      (let ([expr-tt (rec expr)]
            [then-tt (rec then)]
            [else-tt (rec else)])
        (begin
          (define expr-t (car expr-tt))
          (define then-t (car then-tt))
          (define else-t (car else-tt))
          (unless (equal? then-t else-t)
                  (raise-syntax-error #f "if: body expression type mismatch" stx))
          (list then-t expr-tt then-tt else-tt)
        ))
      ]
    [(list (? is-#%len? t) expr-stx)
     (define expr-tt (rec expr-stx))
     (define expr-t (car expr-tt))

     (match expr-t
       ;; we are needlessly discarding information about the actual length here :(
       ;; not clear how to solve this --
       ;;   allow type resolver to modify expressions?
       ;;   add a substitution pass after type resolution?
       ;;   provide some API that the back-end can call to do _most_ of the work?
       [`(#%array-type ,_ ,_) (cons type-I expr-tt)]
       [_
        (raise-syntax-error
         #f
         (format "len: argument must be an array; got ~a" expr-t)
         stx)])]
     [(list (? is-#%scoped-var?) scope-id-stx name-stx)
      (define scope-id (syntax-e scope-id-stx))   ; silly that we have to do this...
      (define name (syntax-e name-stx))
      (cons (get-variable-type current-scope stx scope-id name) #f)
      ]
     [(list (? is-#%set-var? t) target-stx expr-stx)
      (let ([target-tt (rec target-stx)]
            [expr-tt (rec expr-stx)])
        (begin
          (define target-t (car target-tt))
          (define expr-t (car expr-tt))
          (unless (equal? target-t expr-t)
                  (raise-syntax-error #f "set!: variable vs expression type mismatch" stx))
          (list type-V target-tt expr-tt)
        ))
      ]
     [(? number? lit) (cons type-I #f)]
     )))


(define (check-function-args stx param-types t-args)
  (unless (equal? (length param-types) (length t-args))
    (raise-syntax-error #f
                        (format "expected ~a arguments, got ~a" (length param-types) (length t-args))
                        stx))
  (for ([p param-types] [arg t-args] [index (range 1 (add1 (length t-args)))])
    (begin
      (unless (equal? p arg)
        (raise-syntax-error #f
                            (format "argument ~a type mismatch: expecting ~a, got ~a" index p arg)
                            stx)))))

(define (get-variable-type scope stx scope-id var-name)
  (define res (scope-lookup-object-type scope scope-id var-name))
  ;; in case of an error, quote the failing type literally, because syntax tracking for types is very poor ATM
  (unless res (raise-syntax-error #f (format "couldn't resolve type of variable ~a" var-name) stx))
  res
)

(define (process-arguments form-db form-def current-scope stx)
  (for/list ([formal-param (form-def-params form-def)]
             [actual-param (cdr (syntax-e stx))])
    (match formal-param
      [`(stx ,_) (resolve-types/form form-db current-scope actual-param)])))

(define (apply-handler form-db form-def handler current-scope stx)
  (define arg-tts (process-arguments form-db form-def current-scope stx))

  ; (for ([arg-tt arg-tts]) (printf "arg-tt ~a\n" arg-tt))
  ;; call (handler stx arg1-t arg2-t ...)
  (cons (apply handler (cons stx (map car arg-tts))) arg-tts))

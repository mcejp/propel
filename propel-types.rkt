#lang racket

(require "module.rkt"
         "propel-models.rkt"
         "propel-names.rkt"
         "propel-syntax.rkt"
         "scope.rkt"
         )

(provide resolve-types)

; in:   AST
; out:  (type . subtree)
;; Note that we only return trees of types which have no useful interpretation without having the original expression
(define (resolve-types f current-scope stx)
  (define rec (curry resolve-types f current-scope))     ; recurse
  ; (printf "resolve-types ~a\n" stx)
  ;stx

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
     [(cons (? is-#%builtin-function? t) name-stx)
      (define name (syntax-e name-stx))
      (cons (get-builtin-function-type current-scope name-stx name) #f)
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
     [(list (? is-#%define? t) var-stx value)
      ;; recurse to value & insert type information
      (define value-tt (rec value))
      (define value-type (car value-tt))

      (match-define (list '#%scoped-var level name) (syntax->datum var-stx))

      (scope-discover-variable-type! current-scope name value-type)
      (cons type-V value-tt)
      ]
     [(list (? is-#%defun? t) name-stx args-stx ret-stx body-stx)
      (define name (syntax-e name-stx))

      (define func-scope
        (scope current-scope
               (add1 (scope-level current-scope))
               (make-hash)
               (make-hash)
               (make-hash)))
      ;; insert arguments
      (for ([arg-stx (syntax-e args-stx)])
        (match-define (list name-stx type-stx) (syntax-e arg-stx))
        (define name (syntax-e name-stx))
        ;(hash-set! (scope-objects func-scope) name (cons '#%argument name-stx))
        ;(scope-insert-variable! func-scope name)
        (scope-discover-variable-type! func-scope name (syntax->datum type-stx))
        )

      (define arg-types (map (lambda (arg-stx) (begin
        (match-define (list name-stx type-stx) (syntax-e arg-stx))
        (syntax->datum type-stx)
        )) (syntax-e args-stx)))

      (define ret-type (syntax->datum ret-stx))

      (scope-discover-variable-type! current-scope name
        (function-type arg-types ret-type))

      (define body-tt (resolve-types f func-scope body-stx))
      ;(list t name-stx args-stx ret-stx body-stx)
      (cons type-V body-tt)
      ]
     #;[(list (? is-#%dot? t) obj field)
        ; 1. recurse to obj
        ; 2. resolve field
        ]
     [(list (? is-#%deftype? t) name-stx definition-stx) (cons type-V #f)]
     [(list (? is-#%external-function? t) name-stx args-stx ret-stx)
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
     [(list (? is-#%scoped-var? t) level-stx name-stx)
      (define level (syntax-e level-stx))   ; silly that we have to do this...
      (define name (syntax-e name-stx))
      (cons (get-variable-type current-scope name-stx level name) #f)
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
     ))


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

(define (get-builtin-function-type scope stx function-name)
  (define res (scope-lookup-object-type scope 0 function-name))
  ;; in case of an error, quote the failing type literally, because syntax tracking for types is very poor ATM
  (unless res (raise-syntax-error #f (format "invalid builtin function ~a (unspecified type)" function-name) stx))
  res
)

(define (get-variable-type scope stx level var-name)
  (define res (scope-lookup-object-type scope level var-name))
  ;; in case of an error, quote the failing type literally, because syntax tracking for types is very poor ATM
  (unless res (raise-syntax-error #f (format "couldn't resolve type of variable ~a" var-name) stx))
  res
)

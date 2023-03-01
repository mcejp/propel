#lang racket

(require "form-db.rkt"
         "model/t-ast.rkt"
         "propel-models.rkt"
         "propel-names.rkt"
         "propel-syntax.rkt"
         "scope.rkt"
         syntax/parse/define)

(provide resolve-types)

(define (resolve-types form-db stx)
  (resolve-types/form form-db (make-module-scope -100) stx))

(define (resolve-types/form form-db current-scope stx)
  (define node (resolve-types/form-inner form-db current-scope stx))
  (unless (t-ast-node? node)
    (error (format "Expected a typed AST node, got ~a for ~a" node stx)))
  ;; TODO: test recursively to ensure that we haven't inserted some non-sense
  node)

(define (resolve-types/form-inner form-db current-scope stx)
  (define rec (curry resolve-types/form form-db current-scope)) ; recurse
  ; (printf "resolve-types ~a\n" stx)
  ;stx

  (define-syntax-parse-rule (make class:id args:expr ...)
    (class stx
      args ...))

  ;; first try to look up a definition in the form database, and use that
  (define form-def (get-form-def-for-stx form-db stx))
  (define form-handler
    (if form-def (hash-ref (form-def-phases form-def) 'types #f) #f))

  (if form-handler
      (apply-handler form-db form-def form-handler current-scope stx)

      (match (syntax-e stx)
        [(list (? is-#%begin? t) stmts ..1)
         (let* ([stmts* (map rec stmts)]
                [last-stmt (last stmts*)]
                [result-t (if (t-ast-expr? last-stmt)
                              (t-ast-expr-type last-stmt)
                              T-ast-builtin-void)])
           (make t-ast-begin result-t stmts*))]
        [(list (? is-#%begin? t)) (make t-ast-begin T-ast-builtin-void '())]
        [(list (? is-#%app? t) callee args ...)
         (begin
           (let* ([callee* (rec callee)]
                  [args* (map rec args)]
                  [callee-t (t-ast-expr-type callee*)])
             (check-function-args stx
                                  (function-type-arg-types callee-t)
                                  (map t-ast-expr-type args*))

             ; (how to deal with overloaded functions...?)
             (define return-t (function-type-ret-type callee-t))

             (make t-ast-app return-t callee* args*)))]
        ;; warning: *absolute dumpster fire ahead*
        [(list (? is-#%construct? t) type-stx args-stx ...)
         (match (syntax->datum type-stx)
           [`(#%array-type (#%builtin-type I) ,length)
            ;; TODO: validate length
            (make t-ast-construct (parse-type type-stx) (map rec args-stx))]
           ['(#%builtin-type V)
            (begin
              (unless (empty? args-stx)
                (raise-syntax-error
                 #f
                 "expected 0 arguments when constructing Void"
                 stx))
              (make t-ast-construct (parse-type type-stx) '()))]
           [_
            (raise-syntax-error #f
                                "only Void type can be currently constructed"
                                stx)])]
        [(list (? is-#%define-or-#%define-var? t) var-stx value)
         ;; recurse to value & insert type information
         (let* ([value* (rec value)] [value-t (t-ast-expr-type value*)])
           ;; TODO: recurse and then match as a structure (and do this for other instances around)
           (match-define (list '#%scoped-var scope-id name)
             (syntax->datum var-stx))

           ;; TODO: should assert that scope-id matches that of the current scope, no?
           (scope-discover-variable-type! current-scope scope-id name value-t)

           (define is-variable (not (is-#%define? t)))
           (make t-ast-define (rec var-stx) value* is-variable))]
        [(list (? is-#%defun? _) var-stx args-stx ret-stx body-stx)
         (define func-scope
           (scope -1
                  current-scope
                  (add1 (scope-level current-scope))
                  (make-hash)
                  (make-hash)
                  (make-hash)))
         ;; insert parameters into scope
         (define params (parse-parameter-list form-db func-scope args-stx))
         (define param-types (map t-ast-parameter-type params))

         (define ret-t (parse-type ret-stx))

         (match-define `(#%scoped-var ,scope-id ,name) (syntax->datum var-stx))
         (scope-discover-variable-type! current-scope
                                        scope-id
                                        name
                                        (function-type param-types ret-t))

         (define body* (resolve-types/form form-db func-scope body-stx))
         (define body-t (t-ast-expr-type body*))

         (unless (equal? body-t ret-t)
           (raise-syntax-error
            #f
            (format
             "defun: ~a: body expression type (~a) does not match declared return type (~a)"
             name
             body-t
             ret-t)
            stx))

         (define var* (rec var-stx))
         (unless (t-ast-scoped-var? var*)
           (error))

         (make t-ast-defun var* params ret-t body*)]
        [(list (? is-#%deftype? _) name-stx definition-stx)
         (make t-ast-deftype (syntax-e name-stx) (parse-type definition-stx))]
        [(list (? is-#%external-function? _)
               name-stx
               params-stx
               ret-stx
               header-stx)
         (define func-scope
           (scope -1
                  current-scope
                  (add1 (scope-level current-scope))
                  (make-hash)
                  (make-hash)
                  (make-hash)))

         (define name (syntax-e name-stx))
         (define params (parse-parameter-list form-db func-scope params-stx))
         (define ret (parse-type ret-stx))
         (define header (syntax->datum header-stx))

         (let ([type (function-type (map t-ast-parameter-type params) ret)])
           (make t-ast-external-function type name params ret header))]
        [(list (? is-#%if? _) cond-stx then-stx else-stx)
         (let* ([cond* (rec cond-stx)]
                [then* (rec then-stx)]
                [else* (rec else-stx)]
                [then-t (t-ast-expr-type then*)]
                [else-t (t-ast-expr-type else*)])
           (begin
             (unless (equal? then-t else-t)
               (raise-syntax-error
                #f
                (format "if: body expression type mismatch: ~a vs ~a"
                        then-t
                        else-t)
                stx))

             (make t-ast-if then-t cond* then* else*)))]
        [(list (? is-#%len? t) expr-stx)
         (define expr* (rec expr-stx))
         (define expr-t (t-ast-expr-type expr*))

         (match expr-t
           ;; we are needlessly discarding information about the actual length here :(
           ;; not clear how to solve this --
           ;;   return a modified expression?
           ;;   add a substitution pass after type resolution?
           ;;   provide some API that the back-end can call to do _most_ of the work?
           [(T-ast-array-type _ _ _) (make t-ast-len T-ast-builtin-int expr*)]
           [_
            (raise-syntax-error
             #f
             (format "len: argument must be an array; got ~a" expr-t)
             stx)])]
        [(list (? is-#%scoped-var?) scope-id-stx name-stx)
         (define scope-id (syntax-e scope-id-stx))
         (define name (syntax-e name-stx))
         (define type (get-variable-type current-scope stx scope-id name))
         (make t-ast-scoped-var type scope-id name)]
        [(list (? is-#%set-var? t) target-stx expr-stx)
         (let* ([target* (rec target-stx)]
                [expr* (rec expr-stx)]
                [target-t (t-ast-expr-type target*)]
                [expr-t (t-ast-expr-type expr*)])
           (begin
             (unless (equal? target-t expr-t)
               (raise-syntax-error #f
                                   "set!: variable vs expression type mismatch"
                                   stx))
             (make t-ast-set-var target* expr*)))]
        [(? number? lit) (make t-ast-literal T-ast-builtin-int lit)])))

(define (check-function-args stx param-types t-args)
  (unless (equal? (length param-types) (length t-args))
    (raise-syntax-error #f
                        (format "expected ~a arguments, got ~a"
                                (length param-types)
                                (length t-args))
                        stx))
  (for ([p param-types] [arg t-args] [index (range 1 (add1 (length t-args)))])
    (begin
      (unless (equal? p arg)
        (raise-syntax-error
         #f
         (format "argument ~a type mismatch: expecting ~a, got ~a" index p arg)
         stx)))))

(define (get-variable-type scope stx scope-id var-name)
  (define res (scope-lookup-object-type scope scope-id var-name))
  ;; in case of an error, quote the failing type literally, because syntax tracking for types is very poor ATM
  (unless res
    (raise-syntax-error #f
                        (format "couldn't resolve type of variable ~a" var-name)
                        stx))
  res)

(define (process-arguments form-db form-def current-scope stx)
  (for/list ([formal-param (form-def-params form-def)]
             [actual-param (cdr (syntax-e stx))])
    (match formal-param
      [`(stx ,_) (resolve-types/form form-db current-scope actual-param)])))

;; handlers at this level receive stx + the appropriately processed arguments and have to return a t-AST node
(define (apply-handler form-db form-def handler current-scope stx)
  (define args* (process-arguments form-db form-def current-scope stx))

  ;; prepend 'stx' to list of arguments
  (apply handler (cons stx args*)))

(define (parse-type type-stx)
  (define type (syntax->datum type-stx))

  (match (syntax-e type-stx)
    [(list (? is-#%array-type? _) element-type length)
     (T-ast-array-type type-stx (parse-type element-type) (syntax-e length))]
    [_
     (cond
       [(equal? type type-I) T-ast-builtin-int]
       [(equal? type type-V) T-ast-builtin-void]
       [else (error (format "unhandled type ~a" type))])]))

(define (parse-parameter-list form-db current-scope stx)
  (map
   (lambda (param-stx)
     (match-define `(,ident-stx ,type-stx) (syntax-e param-stx))
     (match-define `(#%scoped-var ,scope-id ,name) (syntax->datum ident-stx))
     (scope-discover-variable-type! current-scope
                                    scope-id
                                    name
                                    (parse-type type-stx))

     (match (syntax-e param-stx)
       [(list name-stx type-stx)
        (t-ast-parameter param-stx
                         (resolve-types/form form-db current-scope name-stx)
                         (parse-type type-stx))]))
   (syntax-e stx)))

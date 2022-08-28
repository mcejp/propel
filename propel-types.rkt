#lang racket

(require "module.rkt"
         "propel-models.rkt"
         "propel-names.rkt"
         "propel-syntax.rkt"
         "scope.rkt"
         )

(provide resolve-types/function)

(define (resolve-types/function f)
  (let ([body (function-body f)])
       (struct-copy function f [body-type-tree (resolve-types f (function-scope f) body)])
       ))

; in:   AST
; out:  (type . subtree)
(define (resolve-types f current-scope stx)
  (define rec (curry resolve-types f current-scope))     ; recurse
  ;; (println stx)
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

        ; construct new, typed function call
        (cons return-type (cons callee-tt arg-tts))
        )
      ]
     [(cons (? is-#%argument? t) name-stx)
      ; this is already deprecated, but for the moment we play along
      (define name (syntax-e name-stx))
      (cons (get-argument-type f name name-stx) #f)
      ]
     [(cons (? is-#%builtin-function? t) name-stx)
      (define name (syntax-e name-stx))
      (cons (get-builtin-function-type current-scope name-stx name) #f)
      ]
     [(list (? is-#%define? t) name-stx value)
      ;; recurse to value & insert type information
      (define name (syntax-e name-stx))
      (define value-tt (rec value))
      (define value-type (car value-tt))

      (scope-discover-variable-type! current-scope name value-type)
      (cons type-V value-tt)
      ]
     #;[(list (? is-#%dot? t) obj field)
        ; 1. recurse to obj
        ; 2. resolve field
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
     [(cons (? is-#%module-function? t) name-stx)
      ; this is already deprecated, but for the moment we play along
      (define name (syntax-e name-stx))
      (cons (get-module-function-type (function-module f) name name-stx) #f)
      ]
     [(list (? is-#%scoped-var? t) level-stx name-stx)
      (define level (syntax-e level-stx))   ; silly that we have to do this...
      (define name (syntax-e name-stx))
      (cons (get-variable-type current-scope name-stx level name) #f)
      ]
     [(? number? lit) (cons type-I #f)]
     ))


(define (check-function-args stx param-types t-args)
  (for ([p param-types] [arg t-args] [index (range 1 (add1 (length t-args)))])
    (begin
      (unless (eq? p arg)
        (raise-syntax-error #f
                            (format "argument ~a type mismatch: expecting ~a, got ~a" index p arg)
                            stx)))))

(define (get-argument-type f name stx)
  (define arg-type (get-argument-type* name (function-args f)))
  (when (not arg-type) (raise-syntax-error #f "invalid argument" stx))
  arg-type
)

(define (get-argument-type* name args)
  (match args
    [(cons (list arg-name arg-type) rest) (if (equal? arg-name name) arg-type (get-argument-type* name rest))]
    ['() #f]
  )
)

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

(define (get-module-function-type mod function-name stx)
  (let ([f (hash-ref (module-functions mod)
                     function-name
                     (lambda () (raise-syntax-error #f "invalid module function" stx)))])
    (function-type (map cadr (function-args f)) (function-ret f))
  )
)

#lang racket

(require "propel-models.rkt"
         "propel-syntax.rkt"
         )

(provide resolve-types/function)

(define (resolve-types/function f)
  (let ([body (function-body f)])
       (struct-copy function f [body-type-tree (resolve-types f body)])
       ))

(define (is-#%argument? stx) (equal? (syntax-e stx) '#%argument))
(define (is-#%builtin-function? stx) (equal? (syntax-e stx) '#%builtin-function))
(define (is-#%module-function? stx) (equal? (syntax-e stx) '#%module-function))

; in:   AST
; out:  (type . subtree)
(define (resolve-types f stx)
  (define rec (curry resolve-types f))     ; recurse
  ;(print stx)
  ;stx

   (match (syntax-e stx)
     [(list (? is-#%begin? t) stmts ..1)
      (let ([sub-trees (map rec stmts)])
        (cons (car (last sub-trees)) sub-trees)
        )]
     [(list (? is-#%app? t) exprs ..1)
      (begin
        (define callee (car exprs))               ; callee is #<syntax ...>
        (define callee-tt (rec callee))          ; t-callee is (type . #<syntax ...>)
        (define arg-tts (map rec (cdr exprs)))     ; t-args are (list (type . #<syntax ...>) ...)
        (check-function-args (function-type-arg-types (car callee-tt)) (map car arg-tts))

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
      ; this is already deprecated, but for the moment we play along
      (define name (syntax-e name-stx))
      (cons (get-builtin-function-type name name-stx) #f)
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
     [(? number? lit) (cons 'int #f)]
     ))


(define (check-function-args param-types t-args)
  (for ([p param-types] [arg t-args]) (begin
                                        (unless (eq? p arg) (error "argument type mismatch"))
                                        ))
  )

(define builtin-function-types (hash
  '= (function-type (list 'int 'int) 'int)
  '- (function-type (list 'int 'int) 'int)
  '* (function-type (list 'int 'int) 'int)
))

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

(define (get-builtin-function-type function-name stx)
  (hash-ref builtin-function-types
            function-name
            (lambda () (raise-syntax-error #f "invalid builtin" stx)))
)

(define (get-module-function-type mod function-name stx)
  (let ([f (hash-ref (module-functions mod)
                     function-name
                     (lambda () (raise-syntax-error #f "invalid module function" stx)))])
    (function-type (map cadr (function-args f)) (function-ret f))
  )
)

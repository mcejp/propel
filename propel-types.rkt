#lang racket

(require "propel-models.rkt"
         "propel-syntax.rkt"
         )

(provide resolve-types/function)

(define (resolve-types/function f)
  (match f [(function name args ret body module)
            (struct-copy function f [body (resolve-types f body)])]))

(define (is-#%argument? stx) (equal? (syntax-e stx) '#%argument))
(define (is-#%builtin-function? stx) (equal? (syntax-e stx) '#%builtin-function))
(define (is-#%module-function? stx) (equal? (syntax-e stx) '#%module-function))

; in:   untyped AST
; out:  (cons type AST)
(define (resolve-types f stx)
  (define rec (curry resolve-types f))     ; recurse
  ;(print stx)
  ;stx
  (datum->syntax
   stx
   (match (syntax-e stx)
     [(list (? is-#%begin? t) stmts ..1)
      (let ([t-stmts (map rec stmts)])
        ; create typed #begin block as '(<type> #%t-begin <stmt> ...)
        (append (list (car (syntax-e (last t-stmts))) '#%t-begin) t-stmts))
      ]
     [(list (? is-#%app? t) exprs ..1)
      (begin
        (define callee (car exprs))               ; callee is #<syntax ...>
        (define t-callee (rec callee))            ; t-callee is #<(type . #<syntax ...>)>
        (define t-args (map rec (cdr exprs)))     ; t-args are (list #<(type . #<syntax ...>)> ...)
        (check-function-args (function-type-arg-types (syntax-e (car (syntax-e t-callee)))) (map syntax-e t-args))

        ; (how to deal with overloaded functions...?)
        (define return-type (function-type-ret-type (syntax-e (car (syntax-e t-callee)))))

        ; construct new, typed function call
        (list return-type '#%t-app t-callee t-args)
        )
      ]
     [(cons (? is-#%argument? t) name-stx)
      ; this is already deprecated, but for the moment we play along
      (define name (syntax-e name-stx))
      (list (get-argument-type f name name-stx) '#%t-argument name-stx)
      ]
     [(cons (? is-#%builtin-function? t) name-stx)
      ; this is already deprecated, but for the moment we play along
      (define name (syntax-e name-stx))
      (list (get-builtin-function-type name name-stx) '#%t-builtin-function name-stx)
      ]
     #;[(list (? is-#%dot? t) obj field)
        ; 1. recurse to obj
        ; 2. resolve field
        ]
     [(list (? is-#%if? t) expr then else)
      (let ([t-expr (rec expr)]
            [t-then (rec then)]
            [t-else (rec else)])
        (begin
          ; this is soo broken broken broken broken!
          (define t-then-type (syntax-e (car (syntax-e t-then))))
          (define t-else-type (syntax-e (car (syntax-e t-else))))

          (unless (equal? t-then-type t-else-type)
                  (raise-syntax-error #f "if: body expression type mismatch" stx))
          ; create typed #if block as '(<type> #%t-if <expr> <then> <else>)
          (list t-then-type '#%t-if t-expr t-then t-else))
        )
      ]
     [(cons (? is-#%module-function? t) name-stx)
      ; this is already deprecated, but for the moment we play along
      (define name (syntax-e name-stx))
      (list (get-module-function-type (function-module f) name name-stx) '#%t-module-function name-stx)
      ]
     [(? number? lit) (list 'int stx)]
     )
   stx)
  )

(define (check-function-args param-types t-args)
  (for ([p param-types] [arg t-args]) (begin
                                        (unless (eq? p (syntax-e (car arg))) (error "argument type mismatch"))
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

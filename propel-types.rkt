#lang racket

(require "propel-models.rkt"
         "propel-syntax.rkt"
         )

(provide resolve-types/function)

(struct function-type (arg-types ret-type))

(define (resolve-types/function f)
  (match f [(function name args ret body module)
            (struct-copy function f [body (resolve-types f body)])]))

(define (is-#%builtin-function? stx) (equal? (syntax-e stx) '#%builtin-function))

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
        (append (list (car (last t-stmts)) '#%t-begin) t-stmts))
      ]
     [(list (? is-#%app? t) exprs ..1)
      (begin
        (define callee (car exprs))
        (define t-callee (rec callee))
        (define t-args (map rec (cdr exprs)))
        (check-function-args (function-type-arg-types (car t-callee)) t-args)

        ; (how to deal with overloaded functions...?)
        (define return-type (function-type-ret-type (car t-callee)))

        ; construct new, typed function call
        (list return-type '#%t-app t-callee t-args)
        )
      ]
     [(cons (? is-#%builtin-function? t) name)
      (error "not implemented: #%builtin-function")
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
          (unless (= (car t-then) (car t-else)) (error "if: expression type mismatch"))
          ; create typed #if block as '(<type> #%t-if <expr> <then> <else>)
          (list (car t-then) '#%t-if t-expr t-then t-else))
        )
      ]
     )
   stx)
  )

(define (check-function-args param-types t-args)
  (for ([p param-types] [arg t-args]) (begin
                                        (unless (eq? p (car arg)) (error "argument type mismatch"))
                                        ))
  )

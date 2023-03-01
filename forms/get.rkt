#lang racket

(provide register-form/get)

(require "../form-db.rkt"
         "../model/t-ast.rkt"
         racket/syntax-srcloc)

(define (register-form/get ctx)
  (register-form ctx
                 'get
                 '((stx array) (stx index))
                 (hash 'sugar (lambda (array index) `(#%get ,array ,index))))
  (register-form
   ctx
   '#%get
   '((stx array) (stx index))
   (hash 'types
         (lambda (stx array* index*)
           (define array-t (t-ast-expr-type array*))
           (define index-t (t-ast-expr-type index*))

           (unless (equal? index-t T-ast-builtin-int)
             (raise-syntax-error
              #f
              (format "get: index must be an integer; got ~a" index-t)
              stx))

           (match array-t
             [(T-ast-array-type _ element-t _)
              (t-ast-get (syntax-srcloc stx) element-t array* index*)]
             [_
              (raise-syntax-error
               #f
               (format "get: expected an array; got ~a" array-t)
               stx)])))))

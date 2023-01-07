#lang racket

(provide register-form/get)

(require "../form-db.rkt"
         "../scope.rkt")

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
         ;; compute resultant type; sub-tts will be attached automatically
         (lambda (stx array-t index-t)

           (unless (equal? index-t type-I)
             (raise-syntax-error
              #f
              (format "get: index must be an integer; got ~a" index-t)
              stx))

           (match array-t
             [`(#%array-type ,element-t ,_) element-t]
             [_
              (raise-syntax-error
               #f
               (format "get: expected an array; got ~a" array-t)
               stx)])))))

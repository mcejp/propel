#lang racket

(provide register-form/while)

(require "../form-db.rkt"
         "../scope.rkt")

(define (register-form/while ctx)
  (register-form ctx
                 'while
                 '((stx cond) (stx body))
                 (hash 'sugar
                       (lambda (cond
                                 body)
                         `(#%while ,cond ,body))))
  (register-form
   ctx
   '#%while
   '((stx cond) (stx body))
   (hash 'types
         ;; compute resultant type; sub-tts will be attached automatically
         (lambda (cond-t body-t) type-V))))

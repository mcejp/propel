#lang racket

(provide register-form/var)

(require "../form-db.rkt"
         "../scope.rkt")

(define (register-form/var ctx)
  (register-form
   ctx
   'var
   '((symbol name) (stx value))
   (hash 'sugar (lambda (name value) `(#%define-var ,name ,value))))
  (register-form ctx
                 '#%define-var
                 '((stx-raw name) (stx value))
                 (hash 'names
                       (lambda (name-stx value-stx
                                         #:current-scope current-scope
                                         #:recurse recurse
                                         #:stx stx)
                         (define name (syntax-e name-stx))
                         (scope-insert-variable! current-scope name stx)
                         `(#%define-var ,(recurse name-stx) ,value-stx)))))

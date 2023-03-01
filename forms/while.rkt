#lang racket

(provide register-form/while)

(require "../form-db.rkt"
         "../model/t-ast.rkt"
         racket/syntax-srcloc)

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
         (lambda (stx cond* body*)
           (t-ast-while (syntax-srcloc stx) cond* body*)))))

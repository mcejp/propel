#lang racket

(provide (except-out (all-from-out racket) #%module-begin)
         (rename-out [module-begin #%module-begin])
         )

(define-syntax-rule (module-begin body ...)
  (#%module-begin
   (provide propel-module-stx)
    (define propel-module-stx #'(body ...))
    ;(println propel-module-stx)
  ))

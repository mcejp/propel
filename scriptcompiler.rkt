#lang racket

(require (for-syntax racket/function
                     racket/match
                     racket/string
                     syntax/parse
                     )
         syntax/parse/define)

(provide (except-out (all-from-out racket) #%module-begin)
         (rename-out [module-begin #%module-begin])
         defun
         )

;(define (move-camera x y z) "[move camera to x,y,z]")
;(define (game-quit) "[builtin GameQuit()]")


; will we have to implement our own scoping rules?
(define-simple-macro (defstruct name fields ...)
  (defstruct1 name (fields ...))
  )



(define (process-module-functions module-functions)
  (hash-for-each module-functions (lambda (name f) (print (resolve-names/function f)))))




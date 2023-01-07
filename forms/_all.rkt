#lang racket

(provide register-builtin-forms)

(require "get.rkt"
         "while.rkt")

(define (register-builtin-forms ctx)
  (register-form/get ctx)
  (register-form/while ctx))

#lang racket

(provide register-builtin-forms)

(require "get.rkt"
         "var.rkt"
         "while.rkt")

(define (register-builtin-forms ctx)
  (register-form/get ctx)
  (register-form/var ctx)
  (register-form/while ctx))

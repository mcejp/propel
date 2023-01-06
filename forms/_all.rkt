#lang racket

(provide register-builtin-forms)

(require "while.rkt")

(define (register-builtin-forms ctx)
  (register-form/while ctx))

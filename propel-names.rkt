#lang racket

;; NAME RESOLUTION
; for the moment, any symbol that we encounter can refer either to:
; - function argument
; - built-in function

(struct arg-name (name))
(struct builtin-function-name (name))
(struct func-resolved (name args ret body) #:transparent)

(define (resolve-names/function f)
  (match f [(function name args ret body)
            (func-resolved name
                           args
                           ret
                           (resolve-names/function-body f body))]))

(define (resolve-names f stx)
  stx
  )

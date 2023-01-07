#lang racket

(provide (struct-out function-type))

(struct function-type (arg-types ret-type) #:transparent)

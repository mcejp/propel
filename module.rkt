#lang racket

(provide syntax->module
         (struct-out module))

(require "propel-models.rkt"
         "scope.rkt")

(struct module (scope body body-type-tree) #:mutable #:transparent)

(define (syntax->module stx)
  (module (scope base-scope 1 (make-hash) (make-hash) (make-hash)) stx
    #f))

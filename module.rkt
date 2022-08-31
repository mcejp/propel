#lang racket

(provide (struct-out module))

(require "propel-models.rkt"
         "scope.rkt")

(struct module (scope body body-type-tree) #:mutable #:transparent)

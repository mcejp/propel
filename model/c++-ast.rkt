#lang racket

(provide (struct-out t-ast-c++-binary-operator)
         (struct-out t-ast-c++-unary-operator))

(require "t-ast.rkt")

(define-ast-classes
 t-ast-expr
 [t-ast-c++-binary-operator ([op string] [left t-ast-expr] [right t-ast-expr])]
 [t-ast-c++-unary-operator ([op string] [expr t-ast-expr])])

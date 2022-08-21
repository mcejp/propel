#lang racket/base

(require rackunit
         "propel-serialize.rkt"
         "propel-syntax.rkt")

(test-case
 "dot.rkt"
 (define mod (parse-module "tests/dot.rkt"))
 (resolve-forms/module! mod)
 (define ser (serialize-module mod))
 (check-equal?
  ser
  `((get-name
     ((foo Bar))
     str
     (#%begin (#%dot foo name))
     #f
     ((,(string->path "/workspace/lisp-experiments/tests/dot.rkt") 2 0 29 46)
      (#f 0 0 0 46)
      ((#f 1 2 34 8) (#f 0 0 0 8) (#f 0 0 0 8) (#f 0 0 0 8)))))))

(test-case
 "hello.rkt"
 (define mod (parse-module "tests/hello.rkt"))
 (define ser (serialize-module mod))
 (check-equal?
  ser
  `((increment
     ((n int))
     int
     (begin
       (+ n 1))
      #f
     ((,(string->path "/workspace/lisp-experiments/tests/hello.rkt") 2 0 29 44)
      (#f 0 1 1 5)
      ((#f 1 1 32 7) (#f 0 1 1 1) (#f 0 2 2 1) (#f 0 2 2 1)))))))

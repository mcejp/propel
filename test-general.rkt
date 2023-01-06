#lang racket/base

(require rackunit
         "module.rkt"
         "propel-serialize.rkt"
         "propel-syntax.rkt"
         "scope.rkt")

(test-case
 "dot.rkt"
 (define stx (parse-module "tests/dot.rkt"))
 (define mod (syntax->module (resolve-forms (hash) stx)))
 (define ser (serialize-module mod))
 (check-equal?
  ser
  `((#%begin (#%defun get-name ((foo Bar)) str (#%begin (#%dot foo name))))
    #f
    ((,(string->path "#INT#/propel-syntax.rkt") 53 95 1969 2)
     (#f 0 0 0 2)
     ((,(string->path "tests/dot.rkt") -53 -95 -1969 46)
      (#f 0 0 0 46)
      (#f 0 7 7 8)
      ((#f 0 9 9 11) ((#f 0 1 1 9) (#f 0 1 1 3) (#f 0 4 4 3)))
      (#f 0 6 6 3)
      ((#f 0 -28 -28 46)
       (#f 0 0 0 46)
       ((#f 1 2 34 8) (#f 0 0 0 8) (#f 0 0 0 8) (#f 0 0 0 8))))))))

(test-case
 "hello.rkt"
 (define stx (parse-module "tests/hello.rkt"))
 (define mod (syntax->module (resolve-forms (hash) stx)))
 (define ser (serialize-module mod))
 (check-equal?
  ser
  `((#%begin (#%defun increment ((n int)) int (#%begin (#%app + n 1))))
    #f
    ((,(string->path "#INT#/propel-syntax.rkt") 53 95 1969 2)
     (#f 0 0 0 2)
     ((,(string->path "tests/hello.rkt") -53 -95 -1969 44)
      (#f 0 0 0 44)
      (#f 0 7 7 9)
      ((#f 0 10 10 9) ((#f 0 1 1 7) (#f 0 1 1 1) (#f 0 2 2 3)))
      (#f 0 6 6 3)
      ((#f 0 -27 -27 44)
       (#f 0 0 0 44)
       ((#f 1 2 33 7) (#f 0 0 0 7) (#f 0 1 1 1) (#f 0 2 2 1) (#f 0 2 2 1))))))))

#lang racket/base

(require rackunit
         "propel-serialize.rkt")

(define (check-serialization-equal? input expectation)
  (define port (open-input-string input))
  (define stx (read-syntax "input.rkt" port))
  (check-equal? (serialize-expr stx) expectation))

(test-case
 "Literal"
 (check-serialization-equal? "5" (cons 5 (srcloc "input.rkt" #f #f 1 1))))

(test-case "Form"
           (check-serialization-equal?
            "(#%print 5)"
            (cons '(#%print 5)
                  (list (srcloc "input.rkt" #f #f 1 11)
                        (srcloc "input.rkt" #f #f 2 7)
                        (srcloc "input.rkt" #f #f 10 1)))))

(test-case "Cons"
           (check-serialization-equal?
            "(foo . bar)"
            (cons '(foo . bar)
                  (list (srcloc "input.rkt" #f #f 2 3)
                        (srcloc "input.rkt" #f #f 8 3)))))

(test-case "Compression"
           (define example
             (list (srcloc "input.rkt" #f #f 1 11)
                   (srcloc "input.rkt" #f #f 2 7)
                   (srcloc "input.rkt" #f #f 10 1)))
           (check-equal? (compress-srcloc-tree example)
                         '(("input.rkt" 0 0 0 11) (#f 0 0 1 7) (#f 0 0 8 1))))

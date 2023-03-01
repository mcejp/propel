#lang racket

(provide c++-lift-operators)

(require "model/c++-ast.rkt"
         "model/t-ast.rkt"
         "scope.rkt")

(define (c++-lift-operators module)
  (rewrite-ast
   (lambda (node)
     (match node
       ;; handle unary operators
       [(t-ast-app srcloc type (t-ast-scoped-var _ _ #f callee) (list expr))

        (define ops '((not . "!")))

        (define (substitute ops-to-try)
          (if (empty? ops-to-try)
              node
              (match-let ([(cons propel-name c++-operator) (car ops-to-try)])
                (if (equal? callee
                            (hash-ref (scope-objects base-scope) propel-name))
                    (t-ast-c++-unary-operator srcloc type c++-operator expr)
                    ;; try next in the list
                    (substitute (cdr ops-to-try))))))

        (substitute ops)]
       ;; handle binary operators
       ;; TODO: chaining for >2 operands
       [(t-ast-app srcloc
                   type
                   (t-ast-scoped-var _ _ #f callee)
                   (list left right))

        (define ops
          '((+ . "+") (- . "-")
                      (* . "*")
                      (< . "<")
                      (<= . "<=")
                      (> . ">")
                      ; (>= . ">=")
                      (= . "==")
                      (and . "&&")))

        (define (substitute ops-to-try)
          (if (empty? ops-to-try)
              node
              (match-let ([(cons propel-name c++-operator) (car ops-to-try)])
                (if (equal? callee
                            (hash-ref (scope-objects base-scope) propel-name))
                    (t-ast-c++-binary-operator srcloc
                                               type
                                               c++-operator
                                               left
                                               right)
                    ;; try next in the list
                    (substitute (cdr ops-to-try))))))

        (substitute ops)]
       [_ node]))
   module))

#lang racket

(provide compress-srcloc-tree ; not clear if we want to export this, but useful for unit test
         serialize-expr
         serialize-module)

(require "module.rkt"
         "propel-models.rkt"
         "propel-names.rkt"
         "propel-syntax.rkt"
         "scope.rkt"
         racket/serialize
         racket/syntax-srcloc)

(define (serialize-module mod)
  (match-let ([(module functions scope
                 body) mod])
    ;; This is totally weird... we should not be pulling stuff out of the scope.
    ;; Should just serialize the whole thing if that's what's right.
    (define body-ser (serialize-expr body))
    (append (hash-map (scope-types scope) (λ (name f) (serialize-type name f)))
            (hash-map functions (λ (name f) (serialize-function f)))
            (list (car body-ser) (compress-srcloc-tree (cdr body-ser))))))

(define (serialize-function f)
  (match-let ([(function name args ret body body-type-tree module scope) f])
    (begin
      ;; (printf "serialize-func: body ~a\n" body)
      (define body-ser (serialize-expr body))
      (list name
            args
            ret
            (car body-ser)
            body-type-tree
            ;; TODO scope
            (compress-srcloc-tree (cdr body-ser))))))

; return (cons expr-tree srcloc-tree)
(define (serialize-expr stx)
  ;; (printf "serialize-expr: ~a\n" stx)
  (match (syntax-e stx)
    [(list form ...)
     (begin
       ; returns list of cons
       (define serialized (map serialize-expr form))

       ; remap list of cons to cons of lists
       (cons (map car serialized)
             (cons (syntax-srcloc stx) (map cdr serialized)))
       ;serialized
       )]
    [(cons a b)
     (match-let ([(cons expr-a srcloc-a) (serialize-expr a)]
                 [(cons expr-b srcloc-b) (serialize-expr b)])
       (cons (cons expr-a expr-b) (list srcloc-a srcloc-b)))]
    [(? function-type? t) (cons (struct->vector t) (syntax-srcloc stx))]
    [(? literal? lit) (cons lit (syntax-srcloc stx))]
    [(? symbol? sym) (cons sym (syntax-srcloc stx))]))

(define (compress-srcloc-tree tree)
  (match-define (list compressed last-srcloc*)
    (compress-srcloc-tree* tree (srcloc "" 1 0 1 0)))
  compressed)

; if list of srclocs -> build compressed list recursively, updating state after every element
; if plain srcloc -> build one entry, return updated state
(define (compress-srcloc-tree* tree last-srcloc)
  (match tree
    [(list items ...)
     (begin
       ; each sub-tree is either a list of srclocs or plain srcloc...
       (define compressed-subtree '())
       (for ([subtree items])
         (begin
           (match-define (list compressed last-srcloc*)
             (compress-srcloc-tree* subtree last-srcloc))

           (set! compressed-subtree
                 (append compressed-subtree (list compressed)))
           (set! last-srcloc last-srcloc*)))
       (list compressed-subtree last-srcloc))]
    [(? srcloc? tree)
     (begin
       (define last-path (srcloc-source last-srcloc))
       (define path (srcloc-source tree))
       (define line (srcloc-line tree))
       (define column (srcloc-column tree))

       ; for now, coerce these to enable testing
       (when (equal? line #f)
         (set! line 1))
       (when (equal? column #f)
         (set! column 0))

       (list (list (if (equal? path last-path) #f path)
                   (- line (srcloc-line last-srcloc))
                   (- column (srcloc-column last-srcloc))
                   (- (srcloc-position tree) (srcloc-position last-srcloc))
                   (srcloc-span tree))
             (struct-copy srcloc tree [line line] [column column])))]
    ;[#f (list "N/A" last-srcloc)]
    ))

(define (serialize-type name t)
  (list name t))

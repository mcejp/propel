#lang racket

(provide compress-srcloc-tree ; not clear if we want to export this, but useful for unit test
         serialize-expr
         serialize-module)

(require "propel-models.rkt"
         "propel-syntax.rkt"
         racket/syntax-srcloc)

(define (serialize-module body body-type-tree)
  (define body-ser (serialize-expr body))
  (list (car body-ser) body-type-tree (compress-srcloc-tree (cdr body-ser))))

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
    [(? string? str) (cons str (syntax-srcloc stx))]
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

       ; TODO: when path changes, reset also last-srcloc
       ; (in other words, don't try to compute srcloc difference across different files)
       (list (list (if (equal? path last-path) #f (relativize path))
                   (- line (srcloc-line last-srcloc))
                   (- column (srcloc-column last-srcloc))
                   (- (srcloc-position tree) (srcloc-position last-srcloc))
                   (srcloc-span tree))
             (struct-copy srcloc tree [line line] [column column])))]
    ;[#f (list "N/A" last-srcloc)]
    ))

;; Inspect path and if it points into Propel sources, relativize it
(define (relativize path)
  (define propel-src-dir (drop-right (explode-path (syntax-source #'())) 1))
  (define-values (without-prefix remainder)
    (drop-common-prefix (explode-path path) propel-src-dir))

  (if (eq? remainder '())
      (apply build-path
             (cons "#INT#" without-prefix)) ; successfully removed prefix
      path ; prefix does not appear; return original path
      ))

;; Recursively remove prefix sergments from path. Returns #f if path and prefix do not start with tha same segment
(define (remove-prefix path-segments prefix-segments)
  (if (eq? prefix-segments '())
      path-segments ; prefix exhausted
      (if (equal? (car path-segments) (car prefix-segments))
          (remove-prefix (cdr path-segments) (cdr prefix-segments))
          #f)))

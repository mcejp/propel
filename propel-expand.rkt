#lang racket

(provide expand-forms)

(define (expand-forms stx)
  (define rec expand-forms) ; recurse
  ; (printf "expand-forms ~a\n" (syntax-e stx))

  (datum->syntax stx
                 (match (syntax-e stx)
                   ;; TODO: define-transformer
                   ;; TODO: if macro, expand
                   [(? list? exprs) (map rec exprs)]
                   [_ stx])
                 stx))

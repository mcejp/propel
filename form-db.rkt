#lang racket

(provide get-form-def-for-stx
         register-form
         (struct-out form-def))

(struct form-def (params phases))

(define (get-form-def-for-stx form-db stx)
  (define stx-datum (syntax-e stx))
  (define form-1st-token (if (pair? stx-datum) (syntax-e (car stx-datum)) #f))
  (define form-symbol (if (symbol? form-1st-token) form-1st-token #f))
  (if form-symbol (hash-ref form-db form-symbol #f) #f))

(define (register-form ctx form-symbol params phases)
  (when (hash-has-key? ctx form-symbol)
    (error "form already defined"))
  (hash-set! ctx form-symbol (form-def params phases)))

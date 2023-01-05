#lang racket

(provide expand-forms
         make-expander-state)

(define-namespace-anchor ns)

(struct expander-state (transformers))

(define (make-expander-state)
  (expander-state (make-hash)))

(define (is-define-transformer? stx)
  (equal? (syntax-e stx) 'define-transformer))

(define (expand-forms state stx)
  (expand-forms* (expander-state-transformers state) stx))

;; TODO: macro scoping
(define (expand-forms* transformers stx)
  (define rec (curry expand-forms* transformers)) ; recurse
  ; (printf "expand-forms ~a\n" (syntax-e stx))

  (datum->syntax
   stx
   (match (syntax-e stx)
     ;; handle (define-transformer ...) form
     [(list (? is-define-transformer?) name-stx func-stx)
      (begin
        (hash-set! transformers
                   (syntax->datum name-stx)
                   (eval func-stx (namespace-anchor->namespace ns)))
        '(Void))]

     ;; if macro, expand
     [(list tag-stx args-stx ...)
      (begin
        (define tag (syntax->datum tag-stx))
        (define func (hash-ref transformers tag #f))
        (cond
          ;; Call transformer and cast result to syntax
          ;;
          ;; TODO: This is broken, because it loses srcloc information -- what we'll need to do here
          ;; is to keep track of *both* the macro source code location and the expansion location
          [func (rec (datum->syntax stx (apply func args-stx) stx))]

          ;; Just recurse for the entire form
          [else (map rec (syntax-e stx))]))]

     ;; otherwise pass untouched
     [_ stx])
   stx))

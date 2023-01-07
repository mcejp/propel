;; ONLY PUT MACROS HERE; these will be injected into every module being expanded.
;; Any other syntax is discarded.

(define-transformer for/range (lambda args
  (match-define (list ident-stx max-stx body-stx ...) args)
  `(begin
      (def ,ident-stx 0)
      (while (< ,ident-stx ,max-stx)
            (begin
              ,@body-stx
              (set! ,ident-stx (+ ,ident-stx 1)))))))

;; (make-array-with-type type values ...)
(define-transformer make-array-with-type
                    (lambda args
                      (match-define (list type-stx elem-stx ...) args)
                      `(#%construct (#%array-type ,type-stx ,(length elem-stx))
                                    ,@elem-stx)))

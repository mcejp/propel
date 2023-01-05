;; ONLY PUT MACROS HERE; these will be injected into every module being expanded.
;; Any other syntax is discarded.

(define-transformer make-array-with-type
                    (lambda args
                      (match-define (list type-stx elem-stx ...) args)
                      `(#%construct (#%array-type ,type-stx ,(length elem-stx))
                                    ,@elem-stx)))

;; idea:    at compile time, parse palette file, then generate code to set the vga palette
;; reality: for now it is just a silly example because we don't even have arrays

;; language features still missing:
;;  - get-element
;;  - loops/iteration

(define-transformer make-array-with-type
                    (lambda args
                      (match-define (list type-stx elem-stx ...) args)
                      `(#%construct (#%array-type ,type-stx ,(length elem-stx))
                                    ,@elem-stx)))

(define-transformer *load-palette
                    (lambda (filename)
                      (define the-palette (list 1 2 3 4)) ; TODO: load from file

                      `(make-array-with-type int ,@the-palette)))

(def my-palette (*load-palette "example.pal"))

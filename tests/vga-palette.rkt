;; idea:    at compile time, parse palette file, then generate code to set the vga palette
;; reality: for now it is just a silly example because we don't even have arrays

;; language features still missing:
;;  - get-element
;;  - loops/iteration

(define-transformer *load-palette (lambda (filename)
  (define the-palette (list 1 2 3 4)) ; TODO: load from file

  `(make-array-with-type int ,@the-palette)))

(def my-palette (*load-palette "example.pal"))

(def my-length (len my-palette))

(defun show-palette () Void
  ;; loop & print
  (for/range i (len my-palette)
    (def j i)))

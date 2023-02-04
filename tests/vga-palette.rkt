(for-syntax (require "jascpal.rkt"))

(define-transformer *load-palette (lambda (filename-stx)
  (define the-palette
    (with-input-from-file (syntax-e filename-stx) (lambda ()
      (load-JASC-palette))))

  `(make-array-with-type int ,@(flatten the-palette))))

(def my-palette (*load-palette "tests/endesga-32.pal"))

(def my-length (len my-palette))

(decl-external-fun palette-put ((index int) (value int)) Void #:header "<conio.h>")

(defun show-palette () Void
  ;; loop & print
  (for ([color my-palette])
    (palette-put _i color)))

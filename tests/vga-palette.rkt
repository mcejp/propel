;; idea:    at compile time, parse palette file, then generate code to set the vga palette
;; reality: for now it is just a silly example because we don't even have arrays

(define-transformer
 emit-palette-array
 (lambda (filename)
   (define the-palette (list 1 2 3 4))
   (cons
    'begin
    (for/list ([i the-palette])
      (list 'def (string->symbol (string-append "my-palette-" (~v i))) i)))))

(emit-palette-array "example.pal")

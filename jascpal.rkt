#lang racket

(provide load-JASC-palette)

(define (readln)
  (read-line (current-input-port) 'any))

(define (load-JASC-palette)
  (unless (and (equal? (readln) "JASC-PAL") (equal? (readln) "0100"))
    (error "Not a valid JASC palette file1"))

  (define num-colors (string->number (readln)))
  (unless (and (integer? num-colors) (> num-colors 0) (<= num-colors 256))
    (error "Not a valid JASC palette file"))

  (define colors
    (for/list ([_ (in-range num-colors)])
      (parse-triplet)))
  colors)

(define (syntax-error)
  (error "Syntax error in JASC file"))

(define (parse-triplet)
  (define tokens (string-split (readln) " "))
  (unless (= (length tokens) 3)
    (syntax-error))

  (define values (map string->number tokens))

  (for ([v values])
    (unless (and (integer? v) (>= v 0) (< v 256))
      (syntax-error)))
  values)

#lang s-exp "scriptcompiler.rkt"

(require (for-syntax racket/match))

(define-syntax-rule (dummy-macro x) x)

(define-syntax +ct
  (lambda (stx)
    (match
        (syntax-e stx)
      [(list _ a b) (datum->syntax stx (+ (eval a) (eval b)))])))

#;(defstruct Vec3
  (x real)
  (y real)
  (z real)
  )

(defun flythrough (cam Camera) nil
  (cam.set-pos 0 0 (+ct 1 2))     ; +ct computes a sum at compile time
  ((dummy-macro game-quit))
  )

(defun my-script () nil
  (flythrough (get-scene-camera))
  )

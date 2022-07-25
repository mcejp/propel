#lang racket
(require (for-syntax racket/function
                     racket/match
                     racket/string
                     syntax/parse
                     )
         syntax/parse/define)

(provide (all-from-out racket)
         defun
         )

;(define (move-camera x y z) "[move camera to x,y,z]")
;(define (game-quit) "[builtin GameQuit()]")

; convert x.y.z -> (. (. x y) z)
; tokens must be a non-empty list of strings
; we return a syntax
(define-for-syntax (map-dot-expression stx tokens)
  (define rec (curry map-dot-expression stx))
  ;(display tokens)
  (datum->syntax stx
                 (match tokens
                   [(list a) (string->symbol a)]
                   [(list a ...) `(op-. ,(rec (list (car a))) ,(rec (cdr a )))]
                   )
                 stx)
  )

; map a syntax element that is _not_ a list
; for example, replace `camera.set-pos` with `(. camera set-pos)`
; input: syntax, output: syntax
(define-for-syntax (map-syntax-atom stx)
  (define stxe (syntax-e stx))
  (match stxe
    ; match symbols including stuff like "x.y.z..."
    [(? symbol? sym)
     (map-dot-expression stx (string-split (symbol->string sym) "."))
     ]
    [a a]
    )
  )

; map an AST sub-tree
(define-for-syntax (map-syntax-recursive atom-proc stx)
  ;(display (syntax-e stx))
  (define rec (curry map-syntax-recursive atom-proc))
  (match (syntax-e stx)
    [(list a ...) (datum->syntax stx (map rec a) stx)]
    [a (atom-proc stx)]
    )
  )

; loal-expand-recusrive
; expand recursively without complaining about unbound identifiers
(define-for-syntax (exprec stx)
  ;(display (syntax-e stx))
  (define rec (curry exprec))
  (define (exp stx) (local-expand stx 'expression #f))

  (match (syntax-e stx)
    [(list a ...) (exp (datum->syntax stx (map rec a) stx))]
    [a stx]
    )
  )

(define-for-syntax (map-syntax-all stx)
  (map-syntax-recursive map-syntax-atom stx)
  )

(define-syntax defun1
  (lambda (stx)
    (match (syntax-e stx)
      ; split the different parts of the syntax
      [(list _defun name args ret body)
       (begin
         ; first expand macros, then "map syntax"
         ; done this way so that macro can still use our syntax like 'player.pos'
         (define mapped-form (map-syntax-all (exprec body)))
         (display mapped-form)

         (define quoted-form #`(quote #,mapped-form))
         ; force lexical context of original expression
         (datum->syntax stx (syntax->datum quoted-form) stx)
         ;quoted-form
         )
       ])
    )
  )

(define-simple-macro (defun name args ret body ...)
  (defun1 name args ret (body ...))
  )

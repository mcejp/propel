#lang racket

(provide is-begin?
         resolve-forms
         )

(define (is-begin? stx) (equal? (syntax-e stx) 'begin))

(define (resolve-forms stx)
  (define rec resolve-forms)     ; recurse
  ;(print stx)

  (datum->syntax
   stx
   (match (syntax-e stx)
     [(list (? is-begin? _) stmts ..1) (append '(begin) (map rec stmts))]
     [(? list? exprs) (append '(#%app) (map rec exprs))]
     ; process symbols: replace `camera.set-pos` with `(#%. camera set-pos)`
     [(? symbol? sym) (map-dot-expression stx (string-split (symbol->string sym) "."))]
     [_ stx]
     )
   stx)
  )

; convert player.pos.x -> (#%dot (#%dot player pos) x)
; tokens must be a non-empty list of strings
; we return a new syntax
(define (map-dot-expression stx tokens)
  (define rec (curry map-dot-expression stx))
  ;(display tokens)
  (datum->syntax stx
                 (match tokens
                   [(list a) (string->symbol a)]
                   [(list a ...) (list '#%dot (rec (list (car a))) (rec (cdr a )))]
                   )
                 stx)
  )

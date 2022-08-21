#lang racket

(provide is-#%app?
         is-#%begin?
         is-#%dot?
         is-#%if?
         is-begin?
         literal?
         parse-module
         resolve-forms
         resolve-forms/module!
         )

(require "propel-models.rkt")

(define (is-#%app? stx) (equal? (syntax-e stx) '#%app))
(define (is-#%begin? stx) (equal? (syntax-e stx) '#%begin))
(define (is-#%dot? stx) (equal? (syntax-e stx) '#%dot))
(define (is-#%if? stx) (equal? (syntax-e stx) '#%if))
(define (is-begin? stx) (equal? (syntax-e stx) 'begin))
(define (is-if? stx) (equal? (syntax-e stx) 'if))
(define (literal? lit) (or (number? lit)))

(define (parse-module path)
  (dynamic-require path 'propel-module)
)

(define (resolve-forms/module! mod)
  (define fs (module-functions mod))

  ; Resolve forms in all functions
  (hash-for-each fs (λ (name f) (hash-set!
                                 fs name (struct-copy
                                          function f
                                          [body (resolve-forms (function-body f))]))))
)

(define (resolve-forms stx)
  (define rec resolve-forms)     ; recurse
  ;(print stx)

  (datum->syntax
   stx
   (match (syntax-e stx)
     [(list (? is-begin? _) stmts ..1) (cons '#%begin (map rec stmts))]
     [(list (? is-if? _) expr then else) (list '#%if (rec expr) (rec then) (rec else))]
     [(? list? exprs) (cons '#%app (map rec exprs))]
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

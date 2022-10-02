#lang racket

(provide is-#%app?
         is-#%begin?
         is-#%define?
         is-#%deftype?
         is-#%defun?
         is-#%dot?
         is-#%if?
         is-#%set-var?
         is-begin?
         is-decl-external-fun?
         is-deftype?
         is-defun?
         literal?
         parse-module
         resolve-forms
        ;  resolve-forms/module!
         )

(require "propel-models.rkt"
         "module.rkt"
         "scope.rkt"
)

(define (is-#%app? stx) (equal? (syntax-e stx) '#%app))
(define (is-#%begin? stx) (equal? (syntax-e stx) '#%begin))
(define (is-#%define? stx) (equal? (syntax-e stx) '#%define))
(define (is-#%deftype? stx) (equal? (syntax-e stx) '#%deftype))
(define (is-#%defun? stx) (equal? (syntax-e stx) '#%defun))
(define (is-#%dot? stx) (equal? (syntax-e stx) '#%dot))
(define (is-#%if? stx) (equal? (syntax-e stx) '#%if))
(define (is-#%set-var? stx) (equal? (syntax-e stx) '#%set-var))
(define (is-begin? stx) (equal? (syntax-e stx) 'begin))
(define (is-decl-external-fun? stx) (equal? (syntax-e stx) 'decl-external-fun))
(define (is-define? stx) (equal? (syntax-e stx) 'def))
(define (is-deftype? stx) (equal? (syntax-e stx) 'deftype))
(define (is-defun? stx) (equal? (syntax-e stx) 'defun))
(define (is-if? stx) (equal? (syntax-e stx) 'if))
(define (is-set!? stx) (equal? (syntax-e stx) 'set!))
(define (literal? lit) (or (boolean? lit) (number? lit)))

(define (parse-module path)
  (set! path (string->path path))
  (parameterize ([port-count-lines-enabled #t])
    (with-input-from-file	path (lambda () (begin
      (datum->syntax #'() (sequence->list (in-port (curry read-syntax path))) #'()))))))

(define (resolve-forms stx)
  (define rec resolve-forms)     ; recurse
  ; (printf "resolve-forms ~a\n" (syntax-e stx))

  (datum->syntax
   stx
   (match (syntax-e stx)
     [(list (? is-begin? _) stmts ...) (cons '#%begin (map rec stmts))]
     [(list (? is-decl-external-fun? t) name-stx args-stx ret-stx)
      (list '#%define name-stx (list '#%external-function name-stx args-stx ret-stx))]
     [(list (? is-define? _) name value) (list '#%define name (rec value))]
     [(list (? is-defun? t) name args ret body-stx ...)
      (list '#%defun name args ret (rec (datum->syntax stx (cons #'begin body-stx) stx)))]
     [(list (? is-deftype? t) name definition) (list '#%deftype name definition)]
     [(list (? is-if? _) expr then else) (list '#%if (rec expr) (rec then) (rec else))]
     [(list (? is-set!? _) target expr) (list '#%set-var (rec target) (rec expr))]
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

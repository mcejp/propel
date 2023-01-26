#lang racket

(provide is-#%app?
         is-#%begin?
         is-#%construct?
         is-#%define?
         is-#%define-or-#%define-var?
         is-#%deftype?
         is-#%defun?
         is-#%dot?
         is-#%external-function?
         is-#%if?
         is-#%len?
         is-#%set-var?
         is-begin?
         is-decl-external-fun?
         is-deftype?
         is-defun?
         literal?
         parse-module
         resolve-forms)

(require "form-db.rkt")

(define (is-#%app? stx) (equal? (syntax-e stx) '#%app))
(define (is-#%begin? stx) (equal? (syntax-e stx) '#%begin))
(define (is-#%construct? stx) (equal? (syntax-e stx) '#%construct))
(define (is-#%define? stx) (equal? (syntax-e stx) '#%define))
(define (is-#%define-var? stx) (equal? (syntax-e stx) '#%define-var))
(define (is-#%define-or-#%define-var? stx) (or (is-#%define? stx) (is-#%define-var? stx)))
(define (is-#%deftype? stx) (equal? (syntax-e stx) '#%deftype))
(define (is-#%defun? stx) (equal? (syntax-e stx) '#%defun))
(define (is-#%dot? stx) (equal? (syntax-e stx) '#%dot))
(define (is-#%external-function? stx) (equal? (syntax-e stx) '#%external-function))
(define (is-#%if? stx) (equal? (syntax-e stx) '#%if))
(define (is-#%len? stx) (equal? (syntax-e stx) '#%len))
(define (is-#%set-var? stx) (equal? (syntax-e stx) '#%set-var))
(define (is-begin? stx) (equal? (syntax-e stx) 'begin))
(define (is-decl-external-fun? stx) (equal? (syntax-e stx) 'decl-external-fun))
(define (is-define? stx) (equal? (syntax-e stx) 'def))
(define (is-deftype? stx) (equal? (syntax-e stx) 'deftype))
(define (is-defun? stx) (equal? (syntax-e stx) 'defun))
(define (is-if? stx) (equal? (syntax-e stx) 'if))
(define (is-len? stx) (equal? (syntax-e stx) 'len))
(define (is-set!? stx) (equal? (syntax-e stx) 'set!))
(define (literal? lit) (or (boolean? lit) (number? lit)))

;; Parse a module and return it wrapped with a #'(begin ...) syntax form
(define (parse-module path)
  (set! path (string->path path))
  (parameterize ([port-count-lines-enabled #t])
    (with-input-from-file	path (lambda () (begin
      (define forms (sequence->list (in-port (curry read-syntax path))))
      (define last* (last forms))
      (define module-span (+ (syntax-position last*) (syntax-span last*)))
      ;; FIXME: this will crash upon an empty module
      (define wrapper-srcloc (srcloc path 1 0 1 module-span))
      (datum->syntax #'() (cons 'begin forms) wrapper-srcloc))))))

(define (resolve-forms form-db stx)
  (define rec (curry resolve-forms form-db)) ; recurse
  ; (printf "resolve-forms ~a\n" (syntax-e stx))

  ;; first try to look up a definition in the form database, and use that
  (define form-def (get-form-def-for-stx form-db stx))

  (datum->syntax
   stx
   (if form-def
       (let ([handler (hash-ref (form-def-phases form-def) 'sugar #f)])
         (if handler
             (apply-handler form-db form-def handler stx)
             (apply-default-handler form-db form-def stx)))

   (match (syntax-e stx)
     [(list (? is-begin? _) stmts ...) (cons '#%begin (map rec stmts))]
     ;; for the moment, allow #%construct form on input, since we don't have type recognition implemented for #%app
     ;; (and it may never work for anonymous types)
     [(list (? is-#%construct? t) type-stx args-stx ...) stx]
     [(list (? is-#%external-function? t) name-stx args-stx ret-stx) stx]
     [(list (? is-define? _) name value) (list '#%define name (rec value))]
     [(list (? is-defun? t) name args ret body-stx ...)
      (list '#%defun name args ret (rec (datum->syntax stx (cons #'begin body-stx) stx)))]
     [(list (? is-deftype? t) name definition) (list '#%deftype name definition)]
     [(list (? is-if? _) expr then else) (list '#%if (rec expr) (rec then) (rec else))]
     [(list (? is-len? _) expr) (list '#%len (rec expr))]
     [(list (? is-set!? _) target expr) (list '#%set-var (rec target) (rec expr))]
     [(? list? exprs) (cons '#%app (map rec exprs))]
     ; process symbols: replace `camera.set-pos` with `(#%. camera set-pos)`
     [(? symbol? sym) (map-dot-expression stx (string-split (symbol->string sym) "."))]
     [_ stx]
     ))
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

(define (process-arguments form-db form-def stx)
  (for/list ([formal-param (form-def-params form-def)]
             [actual-param (cdr (syntax-e stx))])
    (match formal-param
      [`(stx ,_) (resolve-forms form-db actual-param)]
      [`(symbol ,_) actual-param])))

(define (apply-handler form-db form-def handler stx)
  (apply handler (process-arguments form-db form-def stx)))

(define (apply-default-handler form-db form-def stx)
  (list* (car (syntax-e stx)) (process-arguments form-db form-def stx)))

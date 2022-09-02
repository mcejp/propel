#lang racket

(require "propel-models.rkt"
         "propel-syntax.rkt"
         "module.rkt"
         "scope.rkt"
         )

(provide is-#%argument?
         is-#%builtin-function?
         is-#%external-function?
         is-#%module-function?
         is-#%scoped-var?
         resolve-names/module!)

(define (is-#%argument? stx) (equal? (syntax-e stx) '#%argument))
(define (is-#%builtin-function? stx) (equal? (syntax-e stx) '#%builtin-function))
(define (is-#%external-function? stx) (equal? (syntax-e stx) '#%external-function))
(define (is-#%module-function? stx) (equal? (syntax-e stx) '#%module-function))
(define (is-#%scoped-var? stx) (equal? (syntax-e stx) '#%scoped-var))

;; NAME RESOLUTION
; for the moment, any symbol that we encounter can refer either to:
; - function argument
; - built-in function
; - program-defined function

(define (resolve-names/module! mod)
  (set-module-body! mod (resolve-names/form #f (module-scope mod) (module-body mod)))
  ;(update-module-types! mod (curry resolve-names/type (module-scope mod)))
  ; (update-module-functions mod resolve-names/function)
)

(define (resolve-names/types-in-arg-list scope args-stx)
  ; (printf "resolve-names/types-in-arg-list ~a\n" args-stx)
  (map
    (lambda (arg) (match (syntax-e arg)
     [(list name-stx type-stx) (list name-stx (resolve-names/type-stx scope type-stx))]))
    (syntax-e args-stx)))

(define (resolve-names/type scope type)
  (define stx #f) ; FIXME
  (match type
    ;; NB: right now we throw away the #%deftype tag... not good, we want to keep that information
    [(list '#%deftype type-expr) (resolve-names/type scope type-expr)]
    [(? symbol? sym) (resolve-type-name scope stx sym)]
    ))

(define (resolve-names/type-stx scope stx)
  ; (printf "resolve-names/type-stx ~a\n" stx)
  (match (syntax-e stx)
    ;; NB: right now we throw away the #%deftype tag... not good, we want to keep that information
    ;[(list '#%deftype type-expr) (resolve-names/type scope type-expr)]
    [(? symbol? sym) (resolve-type-name scope stx sym)]
    ))

(define (resolve-names/form f current-scope stx)
  (define rec (curry resolve-names/form f current-scope))     ; recurse

  ; (printf "resolve-names/form ~a\n" stx)
  ;stx
  (datum->syntax
   stx
   (match (syntax-e stx)
     [(list (? is-#%app? t) exprs ..1) (cons t (map rec exprs))]
     [(list (? is-#%begin? t) stmts ...)
      (define nested-scope
        (scope current-scope
               (add1 (scope-level current-scope))
               (make-hash)
               (make-hash)
               (make-hash)
               #f
               #f))
      (cons t (map (curry resolve-names/form f nested-scope) stmts))
     ]
     [(list (? is-#%define? t) name-stx value) (begin
       (define name (syntax-e name-stx))
       (scope-insert-variable! current-scope name stx)
       (list t (rec name-stx) (rec value))
       )]
     [(list (? is-#%deftype? t) name-stx definition-stx)
      (define resolved-definition (resolve-names/type-stx current-scope definition-stx))
      (hash-set! (scope-types current-scope)
                 (syntax->datum name-stx) ; not great
                 ;(list '#%deftype (syntax->datum definition-stx)) ; bad!
                 resolved-definition
                 )
      (list t name-stx resolved-definition)
      ]
     [(list (? is-#%defun? t) name-stx args-stx ret-stx body-stx)
     (define name (syntax-e name-stx))
      ;; first insert function name into outer scope
      ; (hash-set! (scope-objects current-scope)
      ;            name
      ;            (cons '#%module-function name))
      (scope-insert-variable! current-scope name stx)

      (define func-scope
        (scope current-scope
               (add1 (scope-level current-scope))
               (make-hash)
               (make-hash)
               (make-hash)
               #f
               #f))
      ;; insert arguments
      (for ([arg-stx (syntax-e args-stx)])
        (match-define (list name-stx type-stx) (syntax-e arg-stx))
        (define name (syntax-e name-stx))
        ;(hash-set! (scope-objects func-scope) name (cons '#%argument name-stx))
        (scope-insert-variable! func-scope name stx)
        )

      (define resolved-args (resolve-names/types-in-arg-list current-scope args-stx))
      (define resolved-ret (resolve-type-name current-scope ret-stx (syntax->datum ret-stx))) ; ???

      (list t name-stx resolved-args resolved-ret (resolve-names/form f func-scope body-stx))
      ]
     [(list (? is-#%dot? t) obj field) (list t (rec obj) field)]
     [(list (? is-#%external-function? t) name-stx args-stx ret-stx)
      (list t name-stx
        (resolve-names/types-in-arg-list current-scope args-stx)
        (resolve-names/type-stx current-scope ret-stx))]
     [(list (? is-#%if? t) expr then else) (list t (rec expr) (rec then) (rec else))]
     [(list (? is-#%set-var? t) target expr) (list t (rec target) (rec expr))]
     [(list expr ...) (map rec expr)]
     [(? symbol? sym) (resolve-names/symbol f stx sym current-scope)]
     [(? literal? lit) stx]
     )
   stx)
  )

; resolve symbol
; start by looking in the closest scope and proceed outward
; return a _bound identifier_ structure
(define (resolve-names/symbol f stx sym current-scope)
  ;(define arg (if f (lookup-function-argument f sym stx) #f))
  (define from-scope (scope-try-resolve-symbol current-scope sym))
  (cond
    [from-scope from-scope]
    ;[arg arg]
    [else (raise-syntax-error #f "unresolved symbol" stx)]
    )
  )

(define (resolve-type-names scope stx type-names) (map (curry resolve-type-name scope stx) type-names))

(define (resolve-type-name scope stx type-name)
  (define res (scope-try-resolve-type scope type-name))
  ;; in case of an error, quote the failing type literally, because syntax tracking for types is very poor ATM
  (unless res (raise-syntax-error #f (format "unkown type name ~a" type-name) stx))
  res
)

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
  (update-module-types! mod (curry resolve-names/type (module-scope mod)))
  (update-module-functions mod resolve-names/function)
)

(define (resolve-names/types-in-arg-list scope args-stx)
  (map (lambda (arg) (match (syntax-e arg) [(list name-stx type-stx) (list name-stx (resolve-type-name scope type-stx (syntax->datum type-stx)))]))
       (syntax-e args-stx)))

(define (resolve-names/function f)
  (define outer-scope (module-scope (function-module f)))

  (let* ([args (function-args f)]
         [ret (function-ret f)]
         [body (function-body f)]
         ;; these are a poor approximation, we can do better
         [args-stx body]
         [ret-stx body])
    (struct-copy function
                 f
                 [args (resolve-names/types-in-arg-list outer-scope (datum->syntax args-stx args args-stx))]
                 [ret (resolve-type-name outer-scope ret-stx ret)]
                 [body (resolve-names/form f (function-scope f) body)])))

(define (resolve-names/type scope type)
  (define stx #f) ; FIXME
  (match type
    ;; NB: right now we throw away the #%deftype tag... not good, we want to keep that information
    [(list '#%deftype type-expr) (resolve-names/type scope type-expr)]
    [(? symbol? sym) (resolve-type-name scope stx sym)]
    ))

(define (resolve-names/type-stx scope stx)
  (match (syntax-e stx)
    ;; NB: right now we throw away the #%deftype tag... not good, we want to keep that information
    ;[(list '#%deftype type-expr) (resolve-names/type scope type-expr)]
    [(? symbol? sym) (resolve-type-name scope stx sym)]
    ))

(define (resolve-names/form f current-scope stx)
  (define rec (curry resolve-names/form f current-scope))     ; recurse

  ;(printf "resolve-names/form ~a\n" stx)
  ;stx
  (datum->syntax
   stx
   (match (syntax-e stx)
     [(list (? is-#%app? t) exprs ..1) (cons t (map rec exprs))]
     [(list (? is-#%begin? t) stmts ...) (cons t (map rec stmts))]
     [(list (? is-#%define? t) name-stx value) (begin
       (define name (syntax-e name-stx))
       (scope-insert-variable! current-scope name)
       (list t name-stx (rec value))
       )]
     [(list (? is-#%dot? t) obj field) (list t (rec obj) field)]
     [(list (? is-#%external-function? t) name-stx args-stx ret-stx)
      (list t name-stx
        (resolve-names/types-in-arg-list current-scope args-stx)
        (resolve-names/type-stx current-scope ret-stx))]
     [(list (? is-#%if? t) expr then else) (list t (rec expr) (rec then) (rec else))]
     [(list (? is-defun? t) name args ret body ...) 0]      ; !!!!
     [(list (? is-deftype? t) name definition) 0]           ; !!!!
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
  (define arg (if f (lookup-function-argument f sym stx) #f))
  (define from-scope (scope-try-resolve-symbol current-scope sym))
  (cond
    [from-scope from-scope]
    [arg arg]
    [else (raise-syntax-error #f "unresolved symbol" stx)]
    )
  )

(define (lookup-function-argument f sym stx)
  ; iterate function arguments
  (lookup-function-argument* (function-args f) sym stx)
  )

(define (lookup-function-argument* args sym stx)
  (cond
    [(empty? args) #f]
    [(equal? (car (car args)) sym) (cons '#%argument stx)]
    [else (lookup-function-argument* (cdr args) sym stx)])
  )

;; TODO: the names of these functions should be consistent with the above (like resolve-name/...)
(define (resolve-type-names scope stx type-names) (map (curry resolve-type-name scope stx) type-names))

(define (resolve-type-name scope stx type-name)
  (define res (scope-try-resolve-type scope type-name))
  ;; in case of an error, quote the failing type literally, because syntax tracking for types is very poor ATM
  (unless res (raise-syntax-error #f (format "unkown type name ~a" type-name) stx))
  res
)

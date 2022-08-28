#lang racket

(require "propel-models.rkt"
         "propel-syntax.rkt"
         "module.rkt"
         "scope.rkt"
         )

(provide is-#%argument?
         is-#%builtin-function?
         is-#%module-function?
         resolve-names/module!)

(define (is-#%argument? stx) (equal? (syntax-e stx) '#%argument))
(define (is-#%builtin-function? stx) (equal? (syntax-e stx) '#%builtin-function))
(define (is-#%module-function? stx) (equal? (syntax-e stx) '#%module-function))

;; NAME RESOLUTION
; for the moment, any symbol that we encounter can refer either to:
; - function argument
; - built-in function
; - program-defined function

(define (resolve-names/module! mod)
  (update-module-types! mod (curry resolve-names/type (module-scope mod)))
  (update-module-functions mod resolve-names/function)
)

(define (resolve-names/function f)
  (define outer-scope (module-scope (function-module f)))

  (let ([args (function-args f)] [ret (function-ret f)] [body (function-body f)])
    (struct-copy function
                 f
                 [args
                  (map (match-lambda
                         [(list name type) (list name (resolve-type-name outer-scope type))])
                       args)]
                 [ret (resolve-type-name outer-scope ret)]
                 [body (resolve-names/form f (function-scope f) body)])))

(define (resolve-names/type scope type)
  (match type
    ;; NB: right now we throw away the #%deftype tag... not good, we want to keep that information
    [(list '#%deftype type-expr) (resolve-names/type scope type-expr)]
    [(? symbol? sym) (resolve-type-name scope sym)]
    ))

(define (resolve-names/form f current-scope stx)
  (define rec (curry resolve-names/form f current-scope))     ; recurse
  ;(print stx)
  ;stx
  (datum->syntax
   stx
   (match (syntax-e stx)
     [(list (? is-#%app? t) exprs ..1) (cons t (map rec exprs))]
     [(list (? is-#%begin? t) stmts ..1) (cons t (map rec stmts))]
     [(list (? is-#%dot? t) obj field) (list t (rec obj) field)]
     [(list (? is-#%if? t) expr then else) (list t (rec expr) (rec then) (rec else))]
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
  (define arg (lookup-function-argument f sym stx))
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
(define (resolve-type-names scope type-names) (map (curry resolve-type-name scope) type-names))

(define (resolve-type-name scope type-name)
  (define res (scope-try-resolve-type scope type-name))
  (unless res (error (format "fuuuu ~a" type-name)))
  res
)

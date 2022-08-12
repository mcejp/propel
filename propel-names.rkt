#lang racket

(require "propel-models.rkt"
         "propel-syntax.rkt"
         )

(provide resolve-names/function)

;; NAME RESOLUTION
; for the moment, any symbol that we encounter can refer either to:
; - function argument
; - built-in function
; - program-defined function

(define (resolve-names/function f)
  (match f [(function name args ret body module)
            (struct-copy function f [body (resolve-names f body)])]))

(define (literal? lit) (or (number? lit)))

(define (resolve-names f stx)
  (define rec (curry resolve-names f))     ; recurse
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
     [(? symbol? sym) (resolve-names/symbol f stx sym)]
     [(? literal? lit) stx]
     )
   stx)
  )

(define builtins (set 'game-quit
                      'get-scene-camera
                      '=
                      '-
                      '*
                      ))

; resolve symbol
; start by looking in the closest scope and proceed outward
; return a _bound identifier_ structure
(define (resolve-names/symbol f stx sym)
  (define arg (lookup-function-argument f sym))
  (define module-func (lookup-module-function (function-module f) sym))
  (cond
    [arg arg]
    [module-func module-func]
    [(set-member? builtins sym) (cons '#%builtin-function sym)]
    [else (raise-syntax-error #f "unresolved symbol" stx)]
    )
  )

(define (lookup-function-argument f sym)
  ; iterate function arguments
  (lookup-function-argument* (function-args f) sym)
  )

(define (lookup-function-argument* args sym)
  (cond
    [(empty? args) #f]
    [(equal? (car (car args)) sym) (cons '#%arg-name sym)]
    [else (lookup-function-argument* (cdr args) sym)])
  )

(define (lookup-module-function mod sym)
  (define func (hash-ref (module-functions mod) sym #f))
  (if func (cons '#%module-function sym) #f)
  )
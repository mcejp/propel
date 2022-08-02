#lang racket

(require syntax/parse
         "propel-syntax.rkt")

(provide resolve-names/function)

;; NAME RESOLUTION
; for the moment, any symbol that we encounter can refer either to:
; - function argument
; - built-in function
; - program-defined function

;(struct arg-name (name) #:transparent)
;(struct builtin-function-name (name) #:transparent)
(struct func-resolved (name args ret body module) #:transparent)

(define (resolve-names/function f)
  (match f [(function name args ret body module)
            (func-resolved name
                           args
                           ret
                           (resolve-names f body)
                           module)]))

(define (is-begin? stx) (and (identifier? stx) (equal? (syntax-e stx) 'begin)))
(define (is-#%dot? stx) (equal? (syntax-e stx) '#%dot))

(define (literal? lit) (or (number? lit)))

(define (resolve-names f stx)
  (define rec (curry resolve-names f))     ; recurse
  ;(print stx)
  ;stx
  (datum->syntax stx
                 (match (syntax-e stx)
                   [(list (? is-begin? _) stmt ...) (map rec stmt)]
                   [(list (? is-#%dot? _) obj field) (list '#%dot (rec obj) field)]
                   [(list expr ...) (map rec expr)]
                   [sym #:when (symbol? sym) (resolve-names/symbol f sym)]
                   [lit #:when (literal? lit) stx]
                   )
                 stx)

  #;(syntax-parse stx
      #:literals [begin]
      [(begin stmts ...+) #`(#,(map rec (stmts ...)))]
      ;[(_ (cond a b) #'"cond!"])
      )

  #;(syntax-case stx (begin)
      [(begin stmts ...+) (map rec stmts)]
      ;[(begin stmts ...+) (lambda (stmts) (map rec stmts))]
      ;[(_ (cond a b) #'"cond!"])
      )
  )

(define builtins (set 'game-quit
                      'get-scene-camera
                      ))

; resolve symbol
; start by looking in the closest context and proceed outward
; return a _bound identifier_ structure
(define (resolve-names/symbol f sym)
  (define arg (lookup-function-argument f sym))
  (define module-func (lookup-module-function (function-module f) sym))
  (cond
    [arg arg]
    [module-func module-func]
    [(set-member? builtins sym) (cons '#%builtin-function sym)]
    [else (error "unresolved symbol" sym)]
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
#lang racket

(provide compile-module-to-c++)

(require "propel-models.rkt"
         "propel-names.rkt"
         "propel-syntax.rkt")

(define (compile-module-to-c++ mod)
  ; iterate functions, generate C++ prototypes
  (define fs (module-functions mod))
  (hash-for-each fs
                 (λ (name f)
                   (begin
                     (printf "~a;\n" (format-function-prototype f)))))
  (newline)
  (hash-for-each fs
                 (λ (name f)
                   (begin
                     (printf "~a {\n" (format-function-prototype f))
                     (format-function-body f)
                     (printf "}\n")))))

(define (format-function-prototype f)
  (define name (function-name f))
  (define ret-type (function-ret f))
  (define param-list-str
    (string-join (map format-parameter-prototype (function-args f)) ", "))
  (format "~a ~a(~a)" ret-type name param-list-str))

(define (format-parameter-prototype prm)
  (match-let ([(list name type) prm]) (format "~a ~a" type name)))

(define (format-function-body f)
  (format-statement (function-body f) (function-body-type-tree f)))

(define current-indent 1)

(define (indent)
  (display (string-append* (make-list current-indent "  "))))

(define (indent+!)
  (set! current-indent (+ current-indent 1)))
(define (indent-!)
  (set! current-indent (- current-indent 1)))

(define (format-statement form type-tree)
  (match-define (cons form-type sub-tts)
    type-tree) ; separate resultant type from type sub-trees
  (match (syntax-e form)
    [(list (? is-#%begin? t) stmts ..1)
     (for ([stmt stmts] [sub-tt sub-tts])
       (format-statement stmt sub-tt))]
    [(list (? is-#%if? t) expr then else)
     (match-define (list expr-tt then-tt else-tt) sub-tts)
     (indent)
     (printf "if (")
     (format-expr expr expr-tt)
     (printf ") {")
     (newline)
     (indent+!)
     (format-statement then then-tt)
     (indent-!)
     (indent)
     (printf "} else {")
     (newline)
     (indent+!)
     (format-statement else else-tt)
     (indent-!)
     (indent)
     (printf "}")
     (newline)]

    [other
     (begin
       (indent)
       (format-expr form type-tree)
       (display ";")
       (newline))]))

(define (format-expr form type-tree)
  (match-define (cons form-type sub-tts)
    type-tree) ; separate resultant type from type sub-trees
  (match (syntax-e form)
    [(list (? is-#%app? t) callee args ...)
     (match-define (cons callee-tt arg-tts) sub-tts)
     (format-expr callee callee-tt)
     (printf "(")
     (for ([arg args] [arg-tt arg-tts] [index (range 0 (length args))])
       (begin
         (format-expr arg arg-tt)
         (unless (= index (- (length args) 1))
           (display ", "))))
     (printf ")")]
    [(cons (? is-#%argument? t) name-stx) (display (syntax-e name-stx))]
    [(cons (? is-#%builtin-function? t) name-stx)
     (printf "builtin_~a" (syntax-e name-stx))]
    [(list (? is-#%if? t) expr then else)
     (match-define (list expr-tt then-tt else-tt) sub-tts)
     (indent)
     (printf "if (")
     (format-expr expr expr-tt)
     (printf ") {")
     (newline)
     (indent+!)
     (format-statement then then-tt)
     (indent-!)
     (indent)
     (printf "} else {")
     (newline)
     (indent+!)
     (format-statement else else-tt)
     (indent-!)
     (indent)
     (printf "}")
     (newline)]
    [(cons (? is-#%module-function? t) name-stx) (display (syntax-e name-stx))]
    [(? number? lit) (display lit)]))

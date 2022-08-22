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
  (define-values (tokens final-expr)
    (format-form (function-body f) (function-body-type-tree f)))
  (print-tokens (append tokens (list (format "return ~a;" final-expr))) 1))

;; https://stackoverflow.com/a/39986599
(define (map-values proc lst1 lst2)
  (define (wrap e1 e2)
    (call-with-values (lambda () (proc e1 e2)) list))
  (apply values (apply map list (map wrap lst1 lst2))))

(define (make-placeholder-variable type)
  (define name "$placeholder$") ; FIXME
  (values (format "~a ~a;" type name) name))

;; Return a pair of
;; 1. a list of _tokens_, each being one of "{", "}" or other string representing one line of source code
;; 2. a string representing the result of the form, or #f if void probably...
;; The reason for this circus is that we do not distinguish statements and expressions, but C++ does.
(define (format-form form type-tree)
  (match-define (cons form-type sub-tts)
    type-tree) ; separate resultant type from type sub-trees
  (match (syntax-e form)
    [(list (? is-#%begin? t) stmts ..1)
     (define my-tokens '())
     (define final-expr
       (for/last ([stmt stmts]
                  [sub-tt sub-tts]
                  [index (range 0 (length stmts))])
         ;; emit tokens for each and also its evaluation becaise we don't know if it has side effects.
         (define-values (tokens expr) (format-form stmt sub-tt))
         ;; this is awful, use fold or something
         (if (= index (sub1 (length stmts)))
             (set! my-tokens (append my-tokens tokens))
             (set! my-tokens
                   (append my-tokens tokens (list (string-append expr ";")))))

         expr))
     (values my-tokens final-expr)]
    [(list (? is-#%if? t) expr then else)
     (match-define (list expr-tt then-tt else-tt) sub-tts)

     (define result-type (car then-tt))
     (define-values (result-placeholder-tokens result-placeholder-name)
       (make-placeholder-variable result-type))

     (define-values (test-tokens test-expr) (format-form expr expr-tt))
     (define-values (then-tokens then-expr) (format-form then then-tt))
     (define-values (else-tokens else-expr) (format-form else else-tt))

     (define self-tokens
       (flatten (list result-placeholder-tokens
                      test-tokens
                      (format "if (~a)" test-expr)
                      "{"
                      then-tokens
                      (format "~a = ~a;" result-placeholder-name then-expr)
                      "}"
                      "else"
                      "{"
                      else-tokens
                      (format "~a = ~a;" result-placeholder-name else-expr)
                      "}")))

     (values self-tokens result-placeholder-name)]
    [(list (? is-#%app? t) callee args ...)
     (match-define (cons callee-tt arg-tts) sub-tts)
     (define-values (callee-tokens callee-expr) (format-form callee callee-tt))

     ;; collect tokens + exprs for all arguments
     (define-values (arg-tokens arg-exprs)
       (map-values format-form args arg-tts))

     ;; build tokens as concatenation of all (incl. callee), finally append the call expr
     (define call-expr
       (string-append callee-expr "(" (string-join arg-exprs ", ") ")"))

     (values (list* callee-tokens arg-tokens) call-expr)]
    [(cons (? is-#%argument? t) name-stx)
     (values '() (symbol->string (syntax-e name-stx)))]
    [(cons (? is-#%builtin-function? t) name-stx)
     (values '() (format "builtin_~a" (symbol->string (syntax-e name-stx))))]
    [(cons (? is-#%module-function? t) name-stx)
     (values '() (symbol->string (syntax-e name-stx)))]
    [(? number? lit) (values '() (number->string lit))]))

(define (print-tokens tokens indent)
  (match tokens
    [(list "{" rest ...)
     (begin
       (print-indent indent)
       (displayln "{")
       (print-tokens rest (add1 indent)))]
    [(list "}" rest ...)
     (begin
       (print-indent (sub1 indent))
       (displayln "}")
       (print-tokens rest (sub1 indent)))]
    [(list str rest ...)
     (begin
       (print-indent indent)
       (displayln str)
       (print-tokens rest indent))]
    ['() #f]))

(define (print-indent indent)
  (display (string-append* (make-list indent "  "))))

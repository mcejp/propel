#lang racket

(provide compile-module-to-c++)

(require "propel-models.rkt"
         "propel-names.rkt"
         "propel-syntax.rkt"
         "module.rkt"
         "scope.rkt")

(define (is-#%while? stx)
  (equal? (syntax-e stx) '#%while))

(define (compile-module-to-c++ mod)
  ;; TODO: generate C++ prototypes

  (displayln
   "\
inline int builtin_eq_ii(int a, int b) { return a == b; }
inline int builtin_add_ii(int a, int b) { return a + b; }
inline int builtin_sub_ii(int a, int b) { return a - b; }
inline int builtin_mul_ii(int a, int b) { return a * b; }
inline int builtin_lessthan_ii(int a, int b) { return (a < b) ? 1 : 0; }
inline int builtin_lesseq_ii(int a, int b) { return (a <= b) ? 1 : 0; }
inline int builtin_greaterthan_ii(int a, int b) { return (a > b) ? 1 : 0; }
inline int builtin_and_ii(int a, int b) { return a && b; }
inline int builtin_not_i(int a) { return a ? 0 : 1; }
")

  (define-values (tokens final-expr)
    (format-form (module-body mod) (module-body-type-tree mod)))
  (print-tokens tokens 0))

(define (format-function-prototype c-name args ret)
  (define param-list-str
    (string-join (map format-parameter-prototype args) ", "))
  (format "~a ~a(~a)" (format-type ret) c-name param-list-str))

(define (format-function-type-as-prototype name type)
  (match-define (function-type args ret) type)
  (define param-list-str (string-join (map format-type args) ", "))
  (format "~a ~a(~a);" (format-type ret) name param-list-str))

(define (format-parameter-prototype prm)
  ;; FIXME: NO NO NO NO NO
  (match-let ([(list name type) prm])
    (format "~a scope2_~a" (format-type type) (sanitize-name name))))

(define (format-type type)
  (cond
    [(function-type? type) "auto"]
    [(equal? type type-I) "int"]
    [(equal? type type-V) "void"]
    [else (error (format "unhandled type ~a" type))]))

;; https://stackoverflow.com/a/39986599
(define (map-values proc lst1 lst2)
  (define (wrap e1 e2)
    (call-with-values (lambda () (proc e1 e2)) list))
  (if (> (length lst1) 0)
      (let () (apply values (apply map list (map wrap lst1 lst2))))
      (values '() '())))

(define placeholder-counter 0)

(define (make-placeholder-variable type)
  (define name (format "tmp~a" placeholder-counter))
  (set! placeholder-counter (add1 placeholder-counter))
  (values (format "~a ~a;" (format-type type) name) name))

(define (is-module-scope-var? stx)
  (match (syntax-e stx)
    [(list (? is-#%scoped-var? t) level-stx name-stx)
     (= (syntax-e level-stx) 1)]
    [else #f]))

;; Return a pair of
;; 1. a list of _tokens_, each being one of "{", "}" or other string representing one line of source code
;; 2. a string representing the result of the form, or #f if void probably...
;; The reason for this circus is that we do not distinguish statements and expressions, but C++ does.
(define (format-form form type-tree)
  ;; (printf "format-form ~a\n" form)
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
                   ;; TODO: should skip over empty strings
                   (append my-tokens tokens (list (string-append expr ";")))))

         expr))
     (values my-tokens final-expr)]
    [(list (? is-#%begin? t)) (values '() "")]
    [(list (? is-#%construct?) type-stx args-stx ...)
     (begin
       (unless (equal? (syntax->datum type-stx) type-V)
         (raise-syntax-error #f
                             "only Void type can be currently constructed"
                             form))
       (unless (empty? args-stx)
         (raise-syntax-error #f
                             "expected 0 arguments when constructing Void"
                             form))
       (values '() ""))]
    [(list (? is-#%define? _) var-stx value)
     (define value-tt sub-tts)
     (define-values (var-tokens var-expr) (format-form var-stx (cons #f #f)))

     (unless (eq? var-tokens '())
       (raise-syntax-error #f "unsupported assignment" form))
     (define value-type (car value-tt))

     ;; special treatment for array constructors
     (define is-array-initialization?
       ;; check if type of value matches `(#%array-type (#%builtin-type I) ,length)
       (and (pair? (syntax-e value))
            (equal? (car (syntax->datum value)) '#%construct)
            (equal? (car value-type) '#%array-type)))

     ;; special treatment for function defines
     ;; (not sure if this is the cleanest approach)
     (define is-#%define-external-function?
       (and (list? (syntax-e value))
            (is-#%external-function? (car (syntax-e value)))))

     ;; first check for special cases and then fall back to default
     ;; ugly code ahead :( might be better solved with some kind of transformation pre-pass that
     ;; transforms the special cases into another form
     (cond
       [is-array-initialization?
        ;; build a definition like int variable[] = {1, 2, 3};
        (define element-type-str (format-type (list-ref value-type 1)))

        (define the-decl (format "~a ~a[] =" element-type-str var-expr))

        (define args (cddr (syntax-e value)))
        (define arg-tts (cdr value-tt))

        ;; collect tokens + exprs for all arguments
        (define-values (arg-tokens arg-exprs)
          (map-values format-form args arg-tts))

        ;; build tokens as concatenation of all
        (define values-expr (string-join arg-exprs ", "))

        (values (flatten (list arg-tokens the-decl "{" values-expr "}" ";"))
                "")]
       [is-#%define-external-function?
        (unless (is-module-scope-var? var-stx)
          (raise-syntax-error #f "deftype allowed only in module scope" form))
        ;; FIXME: if we want to go this way, we must assert the name of the variable being defined
        ;;        equals the name of the external function
        ;; TODO: add an example of what we emit
        (define-values (value-tokens value-expr) (format-form value value-tt))
        (values value-tokens "")]
       [else
        (let ()
          (define-values (value-tokens value-expr) (format-form value value-tt))
          (values (flatten (list value-tokens
                                 (format "~a ~a = ~a;"
                                         (format-type value-type)
                                         var-expr
                                         value-expr)))
                  ""))])]
    [(list (? is-#%deftype? _) name-stx definition-stx) (values '() "")]
    [(list (? is-#%defun? _) name-stx args-stx ret-stx body-stx)
     (define body-tt sub-tts)
     (define-values (tokens final-expr) (format-form body-stx body-tt))

     (define c-name
       (make-scoped-name
        1
        (syntax->datum name-stx))) ; aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

     (values (flatten (list (format-function-prototype c-name
                                                       (syntax->datum args-stx)
                                                       (syntax->datum ret-stx))
                            "{"
                            tokens
                            (if (equal? (syntax->datum ret-stx) type-V)
                                (format "~a;" final-expr)
                                (format "return ~a;" final-expr))
                            "}"))
             "")]
    [(list (? is-#%if? t) expr then else)
     (match-define (list expr-tt then-tt else-tt) sub-tts)

     (define result-type (car then-tt))

     (define-values (test-tokens test-expr) (format-form expr expr-tt))
     (define-values (then-tokens then-expr) (format-form then then-tt))
     (define-values (else-tokens else-expr) (format-form else else-tt))

     (if (equal? result-type type-V)
         ;; no temporary needed if void
         (let ()
           (begin
             (define self-tokens
               (flatten (list test-tokens
                              (format "if (~a)" test-expr)
                              "{"
                              then-tokens
                              (format "~a;" then-expr)
                              "}"
                              "else"
                              "{"
                              else-tokens
                              (format "~a;" else-expr)
                              "}")))

             (values self-tokens "")))
         (let ()
           (begin
             (define-values (result-placeholder-tokens result-placeholder-name)
               (make-placeholder-variable result-type))
             (define self-tokens
               (flatten
                (list result-placeholder-tokens
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

             (values self-tokens result-placeholder-name))))]
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
    [(list (? is-#%external-function? t) name-stx args-stx ret-stx)
     (define name (sanitize-name (syntax-e name-stx)))
     (values (list (format-function-type-as-prototype name form-type)) name)]
    [(list (? is-#%len?) _)
     (define expr-tt sub-tts)
     (define expr-t (car expr-tt))

     (match expr-t
       [`(#%array-type ,_ ,length) (values '() (~v length))]
       [_
        (raise-syntax-error
         #f
         (format "len: argument must be an array; got ~a" expr-t)
         form)])]
    [(list (? is-#%scoped-var? t) level-stx name-stx)
     (values '()
             (make-scoped-name
              (syntax-e level-stx)
              (syntax-e name-stx)))] ; FIXME: resolve absolute name
    [(list (? is-#%set-var? t) target-stx expr-stx)
     ;; TODO: this will a rewrite to match specific target forms (variable, array element...)
     (match-define (list target-tt expr-tt) sub-tts)
     (define-values (target-tokens target-expr)
       (format-form target-stx target-tt))
     (define-values (expr-tokens expr-expr) (format-form expr-stx expr-tt))
     (unless (eq? target-tokens '())
       (raise-syntax-error #f "unsupported assignment" form))
     (values (flatten (list expr-tokens))
             (format "~a = ~a;" target-expr expr-expr))]
    [(list (? is-#%while? t) cond body)
     (match-define (list cond-tt body-tt) sub-tts)

     (define-values (cond-tokens cond-expr) (format-form cond cond-tt))
     (define-values (body-tokens body-expr) (format-form body body-tt))

     (unless (= 0 (length (flatten cond-tokens)))
       (raise-syntax-error #f "unsupported expression for while" form))

     (define self-tokens
       (flatten (list (format "while (~a)" cond-expr)
                      "{"
                      body-tokens
                      (format "~a;" body-expr)
                      "}")))

     (values self-tokens "")]
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
  (display (string-append* (make-list indent "    "))))

(define (sanitize-name name)
  (string-replace (symbol->string name) "-" "_"))

(define (make-scoped-name level name)
  ;; for the moment, top-level and built-in symbols are unprefixed, while the rest is prefixed with the level
  (if (<= level 1)
      (sanitize-name name)
      (format "scope~a_~a" level (sanitize-name name))))

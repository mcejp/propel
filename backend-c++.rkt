#lang racket

(provide compile-module-to-c++
         use-c-linkage)

(require "propel-models.rkt"
         "model/t-ast.rkt")

(define use-c-linkage (make-parameter #f))

(define placeholder-counter 0)

(define (compile-module-to-c++ mod-t-ast)
  (set! placeholder-counter 0)

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

  (define-values (tokens final-expr) (format-form mod-t-ast))
  (print-tokens tokens 0))

(define (format-function-prototype c-name args ret)
  (define function-pre-attrs-str (if (use-c-linkage) "extern \"C\" " ""))
  (define param-list-str
    (string-join (map format-parameter-prototype args) ", "))
  (format "~a~a ~a(~a)"
          function-pre-attrs-str
          (format-type ret)
          (sanitize-name c-name)
          param-list-str))

(define (format-function-type-as-prototype name type)
  (match-define (function-type args ret) type)
  (define param-list-str (string-join (map format-type args) ", "))
  (format "~a ~a(~a);" (format-type ret) name param-list-str))

(define (format-parameter-prototype prm)
  (match-let ([(t-ast-parameter _ (t-ast-scoped-var _ _ scope-id name) type)
               prm])
    (format "~a ~a" (format-type type) (make-scoped-name scope-id name))))

(define (format-type type)
  (cond
    [(function-type? type) "auto"]
    [(equal? type T-ast-builtin-int) "int"]
    [(equal? type T-ast-builtin-void) "void"]
    [else (error (format "unhandled type ~a" type))]))

;; https://stackoverflow.com/a/39986599
(define (map-values proc lst)
  (define (wrap e)
    (call-with-values (lambda () (proc e)) list))
  (if (> (length lst) 0)
      (let () (apply values (apply map list (map wrap lst))))
      (values '() '())))

(define (make-placeholder-variable type)
  (define name (format "tmp~a" placeholder-counter))
  (set! placeholder-counter (add1 placeholder-counter))
  (values (format "~a ~a;" (format-type type) name) name))

;; Return a pair of
;; 1. a list of _tokens_, each being one of "{", "}" or other string representing one line of source code
;; 2. a string representing the result of the form, or #f if void probably...
;; The reason for this circus is that we do not distinguish statements and expressions, but C++ does.
(define (format-form form)
  ;; (printf "format-form ~a\n" form)

  (match form
    [(t-ast-begin srcloc type (list stmts ...))
     ;; Recall that the begin form evaluates all forms inside for their side effects
     ;; and returns the result of the last one
     ;; Here, for each of the nested form we first emit its tokens and then its expression
     ;; (although we don't care about the result of the expression, we do care about its side effects)
     ;; The exception is the last one, whose expression is passed on as the ultimate result of the `begin` form

     ;; First collect each nested form's tokens + expression in a *backwards* list
     (define-values (sub-tokenss sub-exprs)
       (for/fold ([sub-tokenss* '()] [sub-exprs* '()]) ([stmt stmts])
         (define-values (tokens expr) (format-form stmt))
         (values (cons tokens sub-tokenss*) (cons expr sub-exprs*))))

     ;; Extract the last form's expression and substitute it with an empty string
     (define result-expr (first sub-exprs))
     (set! sub-exprs (cons "" (rest sub-exprs)))

     ;; Now collect the tokens in a list-of-lists
     ;; We left-fold the backwards lists, so the result is forward
     (define my-tokens
       (for/fold ([out-tokens '()]) ([tokens sub-tokenss] [expr sub-exprs])

         ;; if expression non-empty, terminate with a semicolon
         (cons (if (non-empty-string? expr)
                   (list tokens (string-append expr ";"))
                   tokens)
               out-tokens)))
     ;; Now all that remains is to flatten the collected tokens
     (values (flatten my-tokens) result-expr)]
    [(t-ast-begin srcloc type '()) (values '() "")]
    [(t-ast-construct srcloc type args)
     (begin
       (unless (equal? type T-ast-builtin-void)
         (raise-syntax-error #f
                             "only Void type can be currently constructed"
                             form))
       (unless (empty? args)
         (raise-syntax-error #f
                             "expected 0 arguments when constructing Void"
                             form))
       (values '() ""))]
    [(t-ast-define srcloc var value is-variable)
     (define-values (var-tokens var-expr) (format-form var))

     (unless (eq? var-tokens '())
       (raise-syntax-error #f "unsupported assignment" form))
     (define value-type (t-ast-expr-type value))

     ;; special treatment for array constructors
     (define is-array-initialization?
       (match value
         [(t-ast-construct _ (T-ast-array-type _ _ _) _) #t]
         [_ #f]))

     (define optional-const-prefix (if (not is-variable) "const " ""))

     ;; first check for special cases and then fall back to default
     ;; ugly code ahead :( might be better solved with some kind of transformation pre-pass that
     ;; transforms the special cases into another form
     (cond
       [is-array-initialization?
        ;; build a definition like int variable[] = {1, 2, 3};
        (define element-type-str
          (format-type (T-ast-array-type-element-type value-type)))

        (define the-decl
          (format "~a~a ~a[] ="
                  optional-const-prefix
                  element-type-str
                  var-expr))

        (define args (t-ast-construct-args value))

        ;; collect tokens + exprs for all arguments
        (define-values (arg-tokens arg-exprs) (map-values format-form args))

        ;; build tokens as concatenation of all
        (define values-expr (string-join arg-exprs ", "))

        (values (flatten (list arg-tokens the-decl "{" values-expr "};")) "")]
       ;; special treatment for function defines
       [(t-ast-external-function? value)
        ;; FIXME: if we want to go this way, we must assert the name of the variable being defined
        ;;        equals the name of the external function
        ;; TODO: add an example of what we emit
        (define-values (value-tokens value-expr) (format-form value))
        (values value-tokens "")]
       [else
        (let ()
          (define-values (value-tokens value-expr) (format-form value))
          (values (flatten (list value-tokens
                                 (format "~a~a ~a = ~a;"
                                         optional-const-prefix
                                         (format-type value-type)
                                         var-expr
                                         value-expr)))
                  ""))])]
    [(t-ast-deftype srcloc name definition) (values '() "")]
    [(t-ast-defun srcloc var args ret body)
     (define-values (tokens final-expr) (format-form body))

     (match-define (t-ast-scoped-var _ _ scope-id name) var)

     (define c-name (string->symbol (make-scoped-name scope-id name)))

     (define optional-return-statement
       (if (non-empty-string? final-expr)
           (if (equal? ret T-ast-builtin-void)
               (format "~a;" final-expr)
               (format "return ~a;" final-expr))
           '()))

     (values (flatten (list (format-function-prototype c-name args ret)
                            "{"
                            tokens
                            optional-return-statement
                            "}"))
             "")]
    [(t-ast-if srcloc type expr then else)
     (define-values (test-tokens test-expr) (format-form expr))
     (define-values (then-tokens then-expr) (format-form then))
     (define-values (else-tokens else-expr) (format-form else))

     (if (equal? type T-ast-builtin-void)
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
               (make-placeholder-variable type))
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
    [(t-ast-app srcloc type callee args)
     (define-values (callee-tokens callee-expr) (format-form callee))

     ;; collect tokens + exprs for all arguments
     (define-values (arg-tokens arg-exprs) (map-values format-form args))

     ;; build tokens as concatenation of all (incl. callee), finally append the call expr
     (define call-expr
       (string-append callee-expr "(" (string-join arg-exprs ", ") ")"))

     (values (list* callee-tokens arg-tokens) call-expr)]
    [(t-ast-external-function srcloc type name args ret header)
     (set! name (sanitize-name name))
     (define proto (format-function-type-as-prototype name type))

     ;; TODO: collect all #includes in a module and emit them in a block
     (define my-tokens (list (if header (format "#include ~a" header) proto)))
     (values my-tokens name)]
    ;; TODO: should be implemented with some simple pattern
    [(t-ast-get srcloc type array index)
     (define-values (array-tokens array-expr) (format-form array))
     (define-values (index-tokens index-expr) (format-form index))

     (define my-tokens (flatten (list array-tokens index-tokens)))
     (define my-expr (format "~a[~a]" array-expr index-expr))

     (values my-tokens my-expr)]
    [(t-ast-len srcloc type array)
     (define expr-t (t-ast-expr-type array))

     (match expr-t
       [(T-ast-array-type _ _ length) (values '() (~v length))]
       [_
        (raise-syntax-error
         #f
         (format "len: argument must be an array; got ~a" expr-t)
         form)])]
    [(t-ast-literal srcloc type lit) (values '() (number->string lit))]
    [(t-ast-scoped-var srcloc type scope-id name)
     (values '() (make-scoped-name scope-id name))]
    [(t-ast-set-var srcloc target value)
     ;; TODO: this will a rewrite to match specific target forms (variable, array element...)

     (define-values (target-tokens target-expr) (format-form target))
     (define-values (expr-tokens expr-expr) (format-form value))
     (unless (eq? target-tokens '())
       (raise-syntax-error #f "unsupported assignment" form))
     (values (flatten (list expr-tokens))
             (format "~a = ~a;" target-expr expr-expr))]
    [(t-ast-while srcloc cond body)
     (define-values (cond-tokens cond-expr) (format-form cond))
     (define-values (body-tokens body-expr) (format-form body))

     (unless (= 0 (length (flatten cond-tokens)))
       (raise-syntax-error #f "unsupported expression for while" form))

     (define self-tokens
       (flatten (list (format "while (~a)" cond-expr)
                      "{"
                      body-tokens
                      (format "~a;" body-expr)
                      "}")))

     (values self-tokens "")]))

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
    [(list "};" rest ...)
     (begin
       (print-indent (sub1 indent))
       (displayln "};")
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
  (string-replace (symbol->string name) #px"[^\\w]" "_"))

(define (make-scoped-name scope-id name)
  ;; for the moment, module-level and built-in symbols are unprefixed, while the rest is prefixed with the level
  (if (or (equal? scope-id #f) (equal? scope-id 0))
      (sanitize-name name)
      (format "~a_~a" (sanitize-name name) scope-id)))

#lang racket

(provide compile-module-to-c++
         use-c-linkage)

(require "propel-models.rkt"
         "model/c++-ast.rkt"
         "model/t-ast.rkt")

(define use-c-linkage (make-parameter #f))

(define placeholder-counter 0)

(define (compile-module-to-c++ mod-t-ast)
  (set! placeholder-counter 0)

  ;; TODO: generate C++ prototypes

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

;; Return a pair of
;; 1. a list of _tokens_, each being one of "{", "}" or other string representing one line of source code
;; 2. a string representing the result of the form, or #f if void probably...
;; The reason for this circus is that we do not distinguish statements and expressions, but C++ does.
(define (format-form form)
  ;; (printf "format-form ~a\n" form)

  (match form
    [(t-ast-begin _ type (list stmts ...))
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
    [(t-ast-begin _ type '()) (values '() "")]
    [(t-ast-construct _ type args)
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
    [(t-ast-define _ var value is-variable)
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

        ;; collect exprs for all arguments
        (define arg-exprs (map format-expression args))

        ;; build tokens as concatenation of all
        (define values-expr (string-join arg-exprs ", "))

        (values (flatten (list the-decl "{" values-expr "};")) "")]
       ;; special treatment for function defines
       [(t-ast-external-function? value)
        ;; FIXME: if we want to go this way, we must assert the name of the variable being defined
        ;;        equals the name of the external function
        ;; TODO: add an example of what we emit
        (define-values (value-tokens value-expr) (format-form value))
        (values value-tokens "")]
       [else
        (values (list (format "~a~a ~a = ~a;"
                              optional-const-prefix
                              (format-type value-type)
                              var-expr
                              (format-expression value)))
                "")])]
    [(t-ast-deftype _ name definition) (values '() "")]
    [(t-ast-defun _ var args ret body)
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
    [(t-ast-if _ type cond then else)
     (define cond-expr (format-expression cond))
     (define-values (then-tokens then-expr) (format-form then))
     (define-values (else-tokens else-expr) (format-form else))

     (define self-tokens
       (flatten (list (format "if (~a)" cond-expr)
                      "{"
                      then-tokens
                      (format "~a;" then-expr)
                      "}"
                      "else"
                      "{"
                      else-tokens
                      (format "~a;" else-expr)
                      "}")))

     (values self-tokens "")]
    [(t-ast-external-function _ type name args ret header)
     (set! name (sanitize-name name))
     (define proto (format-function-type-as-prototype name type))

     ;; TODO: collect all #includes in a module and emit them in a block
     (define my-tokens (list (if header (format "#include ~a" header) proto)))
     (values my-tokens name)]
    [(t-ast-set-var _ target value)
     ;; TODO: this will a rewrite to match specific target forms (variable, array element...)

     (define-values (target-tokens target-expr) (format-form target))
     (define value-expr (format-expression value))
     (unless (eq? target-tokens '())
       (raise-syntax-error #f "unsupported assignment" form))
     (values (list (format "~a = ~a;" target-expr value-expr)) "")]
    [(t-ast-while _ cond body)
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

     (values self-tokens "")]
    [_ (values '() (format-expression form))]))

(define (format-expression form)
  ;; (printf "format-form ~a\n" form)

  (match form
    [(t-ast-if _ type expr then else)
     (format "(~a) ? (~a) : (~a)"
             (format-expression expr)
             (format-expression then)
             (format-expression else))]
    [(t-ast-app _ type callee args)
     (define callee-expr (format-expression callee))

     ;; collect tokens + exprs for all arguments
     (define arg-exprs (map format-expression args))

     ;; build tokens as concatenation of all (incl. callee), finally append the call expr
     (string-append callee-expr "(" (string-join arg-exprs ", ") ")")]
    [(t-ast-c++-binary-operator _ type op left right)
     (format "(~a ~a ~a)"
             (format-expression left)
             op
             (format-expression right))]
    [(t-ast-c++-unary-operator _ type op expr)
     (format "(~a~a)" op (format-expression expr))]
    ;; TODO: should be implemented with some simple pattern
    [(t-ast-get _ type array index)
     (define array-expr (format-expression array))
     (define index-expr (format-expression index))

     (format "~a[~a]" array-expr index-expr)]
    [(t-ast-len _ type array)
     (define expr-t (t-ast-expr-type array))

     (match expr-t
       [(T-ast-array-type _ _ length) (number->string length)]
       [_
        (raise-syntax-error
         #f
         (format "len: argument must be an array; got ~a" expr-t)
         form)])]
    [(t-ast-literal _ type lit) (number->string lit)]
    [(t-ast-scoped-var _ type scope-id name) (make-scoped-name scope-id name)]
    [_
     (begin
       (raise-syntax-error
        #f
        (format "only an expression form can appear in this position, not ~a"
                (ast-node-class-name form))
        (t-ast-node-src form)))]))

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

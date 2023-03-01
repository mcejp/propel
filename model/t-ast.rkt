#lang racket

(provide (struct-out t-ast-app)
         (struct-out t-ast-begin)
         (struct-out t-ast-construct)
         (struct-out t-ast-define)
         (struct-out t-ast-defun)
         (struct-out t-ast-deftype)
         (struct-out t-ast-expr)
         (struct-out t-ast-external-function)
         (struct-out t-ast-get)
         (struct-out t-ast-if)
         (struct-out t-ast-len)
         (struct-out t-ast-literal)
         (struct-out t-ast-node)
         (struct-out t-ast-parameter)
         (struct-out t-ast-scoped-var)
         (struct-out t-ast-set-var)
         (struct-out t-ast-stmt)
         (struct-out t-ast-while)
         (struct-out T-ast-builtin-type)
         (struct-out T-ast-array-type)
         ast-to-s-expr
         T-ast-builtin-int
         T-ast-builtin-void)

(require racket/generic
         syntax/parse/define)

(define-struct t-ast-node (srcloc))
(define-struct (t-ast-expr t-ast-node) (type))
(define-struct (t-ast-stmt t-ast-node) ())
(define-struct (t-ast-type t-ast-node) ())

;; gen-class-annotations provides introspection into the types of child nodes for a given parent
(define-generics t-ast-node* (gen-class-annotations t-ast-node*))

;; define helper for creating AST node classes
(define-syntax-parse-rule (define-classes
                           super:id
                           (name:id ((attr-name:id attr-type:expr) ...)) ...)
  (begin
    ;; generate struct
    (struct name super (attr-name ...)
      #:transparent
      #:methods gen:t-ast-node*
      [(define (gen-class-annotations node)
         '(attr-type ...))]) ...))

;; nodes that are not expressions nor statements
(define-classes t-ast-node
                [t-ast-parameter ([name t-ast-scoped-var] [type type])])

;; type nodes
(define-classes t-ast-type
                [T-ast-builtin-type ([type-name symbol])]
                [T-ast-array-type ([element-type type] [length integer])])

;; expression nodes
(define-classes
 t-ast-expr
 [t-ast-app ([callee t-ast-expr] [args expr-list])]
 [t-ast-begin ([stmts stmt-list])]
 [t-ast-construct ([args expr-list])]
 [t-ast-external-function
  ([name symbol] [args param-list] [ret type] [header string-or-#f])]
 [t-ast-get ([array t-ast-expr] [index t-ast-expr])]
 [t-ast-if
  ((cond
     t-ast-expr)
   [then t-ast-stmt]
   [else t-ast-stmt])]
 [t-ast-len ([array t-ast-expr])]
 [t-ast-literal ([value literal])]
 [t-ast-scoped-var ([scope-id integer] [name symbol])])

;; statement nodes
(define-classes
 t-ast-stmt
 [t-ast-define ([name t-ast-scoped-var] [value t-ast-expr] [is-variable bool])]
 [t-ast-deftype ([name symbol] [definition type])]
 ;; TODO: elaborate why defun is a special node type instead of re-using define + anon. function
 ;; (it has to do with being limtied to C semantics -- but also isn't set in stone)
 [t-ast-defun
  ([name t-ast-scoped-var] [args param-list] [ret type] [body t-ast-stmt])]
 [t-ast-set-var ([target t-ast-scoped-var] [value t-ast-expr])]
 [t-ast-while
  ((cond
     t-ast-expr)
   [body t-ast-stmt])])

;; built-in types
;; TBD: these should probably not be singletons, instead we should have an equality function that ignores srcloc
(define T-ast-builtin-int (T-ast-builtin-type #f 'I))
(define T-ast-builtin-void (T-ast-builtin-type #f 'V))

(define (ast-to-s-expr node)
  ; (printf "(ast-to-s-expr ~a) -> ~v\n" node (gen-class-annotations node))

  (define-values (type skipped?) (struct-info node))
  (define-values (name inits autos acc mut imms super super-skipped?)
    (struct-type-info type))

  (define mapped-fields
    (map (lambda (i class)
           (let ([field-value (acc node i)])
             (match class
               ['bool field-value]
               ['expr-list (map ast-to-s-expr field-value)]
               ['integer field-value]
               ['literal field-value]
               ['param-list (map ast-to-s-expr field-value)]
               ['stmt-list (map ast-to-s-expr field-value)]
               ['string-or-#f field-value]
               ['symbol field-value]
               ['t-ast-expr (ast-to-s-expr field-value)]
               ['t-ast-scoped-var (ast-to-s-expr field-value)]
               ['t-ast-stmt (ast-to-s-expr field-value)]
               ['type (ast-to-s-expr field-value)])))
         (range 0 inits)
         (gen-class-annotations node)))

  (set! name
        (string->symbol
         (string-replace (string-replace (symbol->string name) "t-ast-" "#%")
                         "T-ast-"
                         "#%")))

  `(,name ,@mapped-fields))

#lang racket

;;; functions need to be top level since we can't support closures (at least for now)
;;; thus, ok to have the same requirement for types

(provide base-scope
         make-module-scope
         (struct-out scope)
         scope-discover-variable-type!
         scope-insert-variable!
         scope-lookup-object-type
         scope-try-resolve-symbol
         scope-try-resolve-type
         type-I
         type-V)

(require "model/t-ast.rkt"
         "propel-models.rkt")

;; for the moment, types are not properly scoped and have to be defined in module top-level
;; this is not "by design", more like "for simplicity" (also for generating C headers etc.)

(define type-I '(#%builtin-type I))
(define type-V '(#%builtin-type V))

;; scope is defined as a reference to a parent scope + hashmaps of the types and objects (functions, variables) it contains
;;
;; object is a hash map of name -> alias. aliases are only used for built-in functions; in user code, the alias should always be equal to name
;; TODO: special names for built-ins is the backend's problem anyway -- should not really be handled here.
;;       unless somehow necessary for operator overloading.
;;
;; object-types is a hash map of name -> type definition

(struct scope
        (id parent
            level
            types
            objects
            object-types)) ; TODO: is `level` still relevant after unique IDs?

(define (scope-insert-variable! s name stx)
  (when (hash-has-key? (scope-objects s) name)
    (raise-syntax-error #f (format "redefinition of ~a" name) stx))
  (hash-set! (scope-objects s) name name))

(define (scope-discover-variable-type! s scope-id* name type)
  ;(unless (hash-has-key? (scope-objects s) name)
  ;  (error "scope-discover-variable-type! called for invalid symbol"))

  (when (hash-has-key? (scope-object-types s) name)
    (raise-syntax-error #f (format "re-typing of ~a" name) #f))

  (hash-set! (scope-object-types s) (cons scope-id* name) type))

(define (scope-lookup-object-type s scope-id* sym)
  (define type (hash-ref (scope-object-types s) (cons scope-id* sym) #f))
  (if type
      type
      (let ([parent (scope-parent s)])
        (if parent (scope-lookup-object-type parent scope-id* sym) #f))))

(define (scope-try-resolve-symbol s sym)
  (define alias (hash-ref (scope-objects s) sym #f))
  (define parent (scope-parent s))
  (cond
    [alias (cons (scope-id s) alias)]
    [parent (scope-try-resolve-symbol parent sym)]
    [else #f]))

;;; result is like:
;;; (#%deftype int)
;;; (#%builtin-type I)
(define (scope-try-resolve-type s sym)
  (define res (hash-ref (scope-types s) sym #f))
  (define parent (scope-parent s))
  (cond
    [res res]
    [parent (scope-try-resolve-type parent sym)]
    [#t #f]))

(define I-to-I (function-type (list T-ast-builtin-int) T-ast-builtin-int))
(define II-to-I
  (function-type (list T-ast-builtin-int T-ast-builtin-int) T-ast-builtin-int))

(define base-scope
  (scope #f
         #f
         0
         (hash 'int type-I 'Void type-V)
         (hash '=
               'builtin-eq-ii
               '+
               'builtin-add-ii
               '-
               'builtin-sub-ii
               '*
               'builtin-mul-ii
               '<
               'builtin-lessthan-ii
               '<=
               'builtin-lesseq-ii
               '>
               'builtin-greaterthan-ii
               'and
               'builtin-and-ii
               'not
               'builtin-not-i)
         (hash (cons #f 'builtin-eq-ii)
               II-to-I
               (cons #f 'builtin-add-ii)
               II-to-I
               (cons #f 'builtin-sub-ii)
               II-to-I
               (cons #f 'builtin-mul-ii)
               II-to-I
               (cons #f 'builtin-lessthan-ii)
               II-to-I
               (cons #f 'builtin-lesseq-ii)
               II-to-I
               (cons #f 'builtin-greaterthan-ii)
               II-to-I
               (cons #f 'builtin-and-ii)
               II-to-I
               (cons #f 'builtin-not-i)
               I-to-I)))

(define (make-module-scope id)
  (scope id base-scope 1 (make-hash) (make-hash) (make-hash)))

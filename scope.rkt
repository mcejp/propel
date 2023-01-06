#lang racket

;;; functions need to be top level since we can't support closures (at least for now)
;;; thus, ok to have the same requirement for types

(provide base-scope
         (struct-out scope)
         scope-discover-variable-type!
         scope-insert-variable!
         scope-lookup-object-type
         scope-try-resolve-symbol
         scope-try-resolve-type
         type-I
         type-V)

(require "propel-models.rkt")

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

(struct scope (parent level types objects object-types))

(define (scope-insert-variable! s name stx)
  (when (hash-has-key? (scope-objects s) name)
    (raise-syntax-error #f (format "redefinition of ~a" name) stx))
  (hash-set! (scope-objects s) name name))

(define (scope-discover-variable-type! s name type)
  ;(unless (hash-has-key? (scope-objects s) name)
  ;  (error "scope-discover-variable-type! called for invalid symbol"))

  (hash-set! (scope-object-types s) name type))

(define (scope-lookup-object-type s level sym)
  (if (= (scope-level s) level)
      (hash-ref (scope-object-types s) sym #f)
      (scope-lookup-object-type (scope-parent s) level sym)))

(define (scope-try-resolve-symbol s sym)
  (define alias (hash-ref (scope-objects s) sym #f))
  (define parent (scope-parent s))
  (cond
    [alias (list '#%scoped-var (scope-level s) alias)]
    [parent (scope-try-resolve-symbol parent sym)]
    [#t #f]))

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

(define I-to-I (function-type (list type-I) type-I))
(define II-to-I (function-type (list type-I type-I) type-I))

(define base-scope
  (scope #f
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
         (hash 'builtin-eq-ii
               II-to-I
               'builtin-add-ii
               II-to-I
               'builtin-sub-ii
               II-to-I
               'builtin-mul-ii
               II-to-I
               'builtin-lessthan-ii
               II-to-I
               'builtin-lesseq-ii
               II-to-I
               'builtin-greaterthan-ii
               II-to-I
               'builtin-and-ii
               II-to-I
               'builtin-not-i
               I-to-I)))

#lang racket

;;; functions need to be top level since we can't support closures (at least for now)
;;; thus, ok to have the same requirement for types

(provide base-scope
         scope
         scope-discover-variable-type!
         scope-insert-variable!
         scope-objects
         scope-try-resolve-object-type
         scope-try-resolve-symbol
         scope-try-resolve-type
         scope-types
         type-I
         type-V)

(require "propel-models.rkt")

;; for the moment, types are not properly scoped and have to be defined in module top-level
;; this is not "by design", more like "for simplicity" (also for generating C headers etc.)

(define type-I '(#%builtin-type I))
(define type-V '(#%builtin-type V))

;; scope is defined as a reference to a parent scope + hashmaps of the types and objects (functions, variables) it contains

(struct scope
        (parent types
                objects
                object-types
                allows-new-types
                allows-new-functions))

(define (scope-insert-variable! s name)
  ;; FIXME: must check for redefinition!!!!
  (hash-set! (scope-objects s) name (cons '#%variable name)))

(define (scope-discover-variable-type! s name type)
  (unless (hash-has-key? (scope-objects s) name)
    (error "scope-discover-variable-type! called for invalid symbol"))

  (hash-set! (scope-object-types s) name type))

(define (scope-try-resolve-object-type s sym)
  (define res (hash-ref (scope-object-types s) sym #f))
  (define parent (scope-parent s))
  (cond
    [res res]
    [parent (scope-try-resolve-object-type parent sym)]
    [#t #f]))

(define (scope-try-resolve-symbol s sym)
  (define res (hash-ref (scope-objects s) sym #f))
  (define parent (scope-parent s))
  (cond
    [res res]
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

(define II-to-I (function-type (list type-I type-I) type-I))

(define base-scope
  (scope #f
         (hash 'int type-I 'Void type-V)
         (hash '=
               ;;(cons II-to-I '(#%builtin-function builtin-eq-ii))
               '(#%builtin-function . builtin-eq-ii)
               '+
               '(#%builtin-function . builtin-add-ii)
               '-
               ;;(cons II-to-I '(#%builtin-function builtin-sub-ii))
               '(#%builtin-function . builtin-sub-ii)
               '*
               ;;(cons II-to-I '(#%builtin-function builtin-mul-ii)))
               '(#%builtin-function . builtin-mul-ii))
         (hash 'builtin-eq-ii
               II-to-I
               'builtin-add-ii
               II-to-I
               'builtin-sub-ii
               II-to-I
               'builtin-mul-ii
               II-to-I)
         #f
         #f))

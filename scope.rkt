#lang racket

;;; functions need to be top level since we can't support closures (at least for now)
;;; thus, ok to have the same requirement for types

(provide base-scope
         builtin-function-types
         scope
         scope-objects
         scope-try-resolve-symbol
         scope-try-resolve-type
         type-I)

(require "propel-models.rkt")

;; for the moment, types are not properly scoped and have to be defined in module top-level
;; this is not "by design", more like "for simplicity" (also for generating C headers etc.)

(define type-I '(#%builtin-type I))

;; scope is defined as a reference to a parent scope + hashmaps of the types and objects (functions, variables) it contains

(struct scope (parent types objects allows-new-types allows-new-functions))

(define (scope-try-resolve-symbol s sym)
  (define res (hash-ref (scope-objects s) sym #f))
  (define parent (scope-parent s))
  (cond
    [res res]
    [parent (scope-try-resolve-symbol parent sym)]
    [#t #f]))

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
         (hash 'int (cons '#%type type-I))
         (hash '=
               ;;(cons II-to-I '(#%builtin-function builtin-eq-ii))
               '(#%builtin-function . builtin-eq-ii)
               '-
               ;;(cons II-to-I '(#%builtin-function builtin-sub-ii))
               '(#%builtin-function . builtin-sub-ii)
               '*
               ;;(cons II-to-I '(#%builtin-function builtin-mul-ii)))
               '(#%builtin-function . builtin-mul-ii))
         #f
         #f))

(define builtin-function-types
  (hash 'builtin-eq-ii II-to-I 'builtin-sub-ii II-to-I 'builtin-mul-ii II-to-I))

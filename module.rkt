#lang racket

(provide iterate-module-functions
         (struct-out module)
         update-module-functions
         update-module-types!)

(require "propel-models.rkt"
         "scope.rkt")

;;; this is super messed up in that we list functions directly,
;;; but types (which may be reference by functions) are inside the module-level scope
(struct module (functions scope body) #:mutable #:transparent)

(define (iterate-module-functions mod cb)
  (define fns (module-functions mod))
  (hash-for-each fns (λ (name f) (cb f))))

(define (update-module-functions mod updater)
  ;; iterate all functions defined in module & pass through updater
  (define fns (module-functions mod))
  (hash-for-each fns
                 (λ (name f)
                   (let ([f* (updater f)])
                     (begin
                       ;(println f*)
                       (hash-set! fns name f*))))))

(define (update-module-types! mod updater)
  ;; iterate all types defined in module-level scope & pass through updater
  (define types (scope-types (module-scope mod)))
  (hash-for-each types
                 (λ (name type)
                   (let ([type* (updater type)])
                     (begin
                       (hash-set! types name type*))))))

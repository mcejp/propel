#lang racket

(provide iterate-module-functions
         module
         module-functions
         module-scope
         update-module-functions)

(require "propel-models.rkt"
         "scope.rkt")

(struct module (functions scope) #:transparent)

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

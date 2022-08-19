#lang racket

(require racket/serialize)

(provide function
         function-name
         function-args
         function-ret
         function-body
         function-module
         function-type
         function-type?
         function-type-arg-types
         function-type-ret-type
         module
         module-functions
         )

(struct module (functions) #:transparent)
(struct function-type (arg-types ret-type) #:transparent)

; (symbol list symbol syntax)
(struct function (name args ret body module) #:mutable #:transparent
  #:property prop:serializable
  (make-serialize-info
   (λ (this)
     (vector (function-name this)
             (function-args this)
             (function-ret this)
             (serialize (syntax->datum (function-body this)))
             (function-module this)))
   'function-deserialize
   #t
   (or (current-load-relative-directory) (current-directory)))
  )

(define function-deserialize
  (make-deserialize-info
   (λ (name args ret stx)
     (function name args ret (syntax-deserialize stx)))
   (λ ()
     (define f (function 'transporter-error 'transporter-error 'transporter-error 'transporter-error))
     (values f
             (λ (name args ret stx)
               (begin
                 (set-function-name! f name)
                 (set-function-args! f args)
                 (set-function-ret! f ret)
                 (set-function-body! (syntax-deserialize stx))
                 (set-function-module! module)
                 ))))))

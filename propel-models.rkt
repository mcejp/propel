#lang racket

(require racket/serialize)

(provide function
         function-name
         function-args
         function-ret
         function-body
         function-body-type-tree
         function-module
         function-type
         function-type?
         function-type-arg-types
         function-type-ret-type
         function-scope
         )

(struct function-type (arg-types ret-type) #:transparent)

; (symbol list symbol syntax list module)
(struct function (name args ret body body-type-tree module scope) #:transparent)

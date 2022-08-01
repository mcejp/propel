#lang racket

(provide function)

; TODO: try if serializable-struct is feasible
(struct function (name args ret body) #:transparent)

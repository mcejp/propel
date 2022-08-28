#lang s-exp "../propel.rkt"

(deftype my-int int)

(defun add ([a my-int] [b my-int]) my-int
  (+ a b))

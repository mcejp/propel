#lang s-exp "../propel.rkt"

(defun add ([a int] [b int]) int
  (def left a)
  (def right b)
  (def sum (+ left right))
  sum)

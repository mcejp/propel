; (provide brd-get brd-count-empty-spots)

(var board (make-array-with-type int 0 0 0 0
                                     0 0 0 0
                                     0 0 0 0
                                     0 0 0 0))

(def W 4)
(def H 4)

(defun brd-get ([x int] [y int]) int
  (get board (+ (* y W) x)))

(defun brd-count-empty-spots () int
  (var empty 0)

  (for/range y H
    (for/range x W
      (when (not (brd-get x y))
        (set! empty (+ empty 1)))))

  empty)

((add
  ((a int) (b int))
  int
  (begin (def left a) (def right b) (def sum (+ left right)) sum)
  #f
  ((#<path:/workspace/lisp-experiments/tests/def-local.rkt> 2 0 29 97)
   (#f 0 1 1 5)
   ((#f 1 1 34 12) (#f 0 1 1 3) (#f 0 4 4 4) (#f 0 5 5 1))
   ((#f 1 -10 5 13) (#f 0 1 1 3) (#f 0 4 4 5) (#f 0 6 6 1))
   ((#f 1 -11 5 24)
    (#f 0 1 1 3)
    (#f 0 4 4 3)
    ((#f 0 4 4 14) (#f 0 1 1 1) (#f 0 2 2 4) (#f 0 5 5 5)))
   (#f 1 -17 10 3))))

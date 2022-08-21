((factorial
  ((n int))
  int
  (begin (if (= n 0) 1 (* n (factorial (- n 1)))))
  #f
  ((#<path:/workspace/lisp-experiments/flyover.rkt> 27 0 503 86)
   (#f 0 1 1 5)
   ((#f 1 1 32 52)
    (#f 0 1 1 2)
    ((#f 0 3 3 7) (#f 0 1 1 1) (#f 0 2 2 1) (#f 0 2 2 1))
    (#f 1 -5 9 1)
    ((#f 1 0 8 25)
     (#f 0 1 1 1)
     (#f 0 2 2 1)
     ((#f 0 2 2 19)
      (#f 0 1 1 9)
      ((#f 0 10 10 7) (#f 0 1 1 1) (#f 0 2 2 1) (#f 0 2 2 1))))))))

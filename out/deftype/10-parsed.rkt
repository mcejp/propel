((my-int (#%deftype int))
 (add
  ((a my-int) (b my-int))
  my-int
  (begin (+ a b))
  #f
  ((#<path:/workspace/lisp-experiments/tests/deftype.rkt> 4 0 51 52)
   (#f 0 1 1 5)
   ((#f 1 1 43 7) (#f 0 1 1 1) (#f 0 2 2 1) (#f 0 2 2 1)))))

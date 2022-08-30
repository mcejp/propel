((my-int (#%deftype int))
 (add
  ((a my-int) (b my-int))
  my-int
  (#%begin (#%app + a b))
  #f
  ((#<path:/workspace/lisp-experiments/tests/deftype.rkt> 4 0 51 52)
   (#f 0 0 0 52)
   ((#f 1 2 44 7) (#f 0 0 0 7) (#f 0 1 1 1) (#f 0 2 2 1) (#f 0 2 2 1)))))

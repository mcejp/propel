((increment
  ((n (#%builtin-type I)))
  (#%builtin-type I)
  (#%begin (#%app (#%builtin-function . builtin-add-ii) (#%argument . n) 1))
  #f
  ((#<path:/workspace/lisp-experiments/tests/hello.rkt> 2 0 29 44)
   (#f 0 0 0 44)
   ((#f 1 2 33 7)
    (#f 0 0 0 7)
    ((#f 0 1 1 1) (#f 0 0 0 1))
    ((#f 0 2 2 1) (#f 0 0 0 1))
    (#f 0 2 2 1)))))

((#%begin
  (#%defun
   increment
   ((n (#%builtin-type I)))
   (#%builtin-type I)
   (#%begin
    (#%app (#%builtin-function . builtin-add-ii) (#%scoped-var 2 n) 1))))
 #f
 ((#<path:/workspace/lisp-experiments/propel-syntax.rkt> 46 80 1638 2)
  (#f 0 0 0 2)
  ((#<path:tests/hello.rkt> -46 -80 -1638 44)
   (#f 0 0 0 44)
   (#f 0 7 7 9)
   ((#f 0 -7 -7 44)
    ((#f 0 0 0 44)
     (#f 0 19 19 1)
     ((#f 0 -19 -19 44) (#f 0 0 0 44) (#f 0 0 0 44))))
   ((#f 0 0 0 44) (#f 0 0 0 44) (#f 0 0 0 44))
   ((#f 0 0 0 44)
    (#f 0 0 0 44)
    ((#f 1 2 33 7)
     (#f 0 0 0 7)
     ((#f 0 1 1 1) (#f 0 0 0 1))
     ((#f 0 2 2 1) (#f 0 0 0 1) (#f 0 0 0 1) (#f 0 0 0 1))
     (#f 0 2 2 1))))))
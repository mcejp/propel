((#%begin
  (#%defun
   increment
   ((n (#%builtin-type I)))
   (#%builtin-type I)
   (#%begin
    (#%app (#%builtin-function . builtin-add-ii) (#%scoped-var 2 n) 1))))
 ((#%builtin-type V)
  ((#%builtin-type V)
   (#%builtin-type I)
   ((#%builtin-type I)
    (#(struct:function-type
       ((#%builtin-type I) (#%builtin-type I))
       (#%builtin-type I))
     .
     #f)
    ((#%builtin-type I) . #f)
    ((#%builtin-type I) . #f))))
 ((#<path:#INT#/propel-syntax.rkt> 48 95 1794 2)
  (#f 0 0 0 2)
  ((#<path:tests/hello.rkt> -48 -95 -1794 44)
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
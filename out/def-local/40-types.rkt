((add
  ((a (#%builtin-type I)) (b (#%builtin-type I)))
  (#%builtin-type I)
  (#%begin
   (#%define left (#%argument . a))
   (#%define right (#%argument . b))
   (#%define
    sum
    (#%app
     (#%builtin-function . builtin-add-ii)
     (#%scoped-var 2 left)
     (#%scoped-var 2 right)))
   (#%scoped-var 2 sum))
  ((#%builtin-type I)
   ((#%builtin-type V) (#%builtin-type I) . #f)
   ((#%builtin-type V) (#%builtin-type I) . #f)
   ((#%builtin-type V)
    (#%builtin-type I)
    (#(struct:function-type
       ((#%builtin-type I) (#%builtin-type I))
       (#%builtin-type I))
     .
     #f)
    ((#%builtin-type I) . #f)
    ((#%builtin-type I) . #f))
   ((#%builtin-type I) . #f))
  ((#<path:/workspace/lisp-experiments/tests/def-local.rkt> 2 0 29 97)
   (#f 0 0 0 97)
   ((#f 1 2 35 12) (#f 0 0 0 12) (#f 0 5 5 4) ((#f 0 5 5 1) (#f 0 0 0 1)))
   ((#f 1 -10 5 13) (#f 0 0 0 13) (#f 0 5 5 5) ((#f 0 6 6 1) (#f 0 0 0 1)))
   ((#f 1 -11 5 24)
    (#f 0 0 0 24)
    (#f 0 5 5 3)
    ((#f 0 4 4 14)
     (#f 0 0 0 14)
     ((#f 0 1 1 1) (#f 0 0 0 1))
     ((#f 0 2 2 4) (#f 0 0 0 4) (#f 0 0 0 4) (#f 0 0 0 4))
     ((#f 0 5 5 5) (#f 0 0 0 5) (#f 0 0 0 5) (#f 0 0 0 5))))
   ((#f 1 -17 10 3) (#f 0 0 0 3) (#f 0 0 0 3) (#f 0 0 0 3)))))

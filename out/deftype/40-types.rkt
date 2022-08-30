((my-int (#%builtin-type I))
 (add
  ((a (#%builtin-type I)) (b (#%builtin-type I)))
  (#%builtin-type I)
  (#%begin
   (#%app
    (#%builtin-function . builtin-add-ii)
    (#%argument . a)
    (#%argument . b)))
  ((#%builtin-type I)
   ((#%builtin-type I)
    (#(struct:function-type
       ((#%builtin-type I) (#%builtin-type I))
       (#%builtin-type I))
     .
     #f)
    ((#%builtin-type I) . #f)
    ((#%builtin-type I) . #f)))
  ((#<path:/workspace/lisp-experiments/tests/deftype.rkt> 4 0 51 52)
   (#f 0 0 0 52)
   ((#f 1 2 44 7)
    (#f 0 0 0 7)
    ((#f 0 1 1 1) (#f 0 0 0 1))
    ((#f 0 2 2 1) (#f 0 0 0 1))
    ((#f 0 2 2 1) (#f 0 0 0 1))))))

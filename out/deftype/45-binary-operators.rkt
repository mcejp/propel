(#%begin
 ((#%deftype my-int (#%builtin-type I))
  (#%defun
   (#%scoped-var 0 add)
   ((#%parameter (#%scoped-var 1 a) (#%builtin-type I))
    (#%parameter (#%scoped-var 1 b) (#%builtin-type I)))
   (#%builtin-type I)
   (#%begin
    ((#%c++-binary-operator "+" (#%scoped-var 1 a) (#%scoped-var 1 b)))))))

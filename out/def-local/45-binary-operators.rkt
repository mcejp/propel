(#%begin
 ((#%defun
   (#%scoped-var 0 add)
   ((#%parameter (#%scoped-var 1 a) (#%builtin-type I))
    (#%parameter (#%scoped-var 1 b) (#%builtin-type I)))
   (#%builtin-type I)
   (#%begin
    ((#%define (#%scoped-var 1 left) (#%scoped-var 1 a) #f)
     (#%define (#%scoped-var 1 right) (#%scoped-var 1 b) #f)
     (#%define
      (#%scoped-var 1 sum)
      (#%c++-binary-operator "+" (#%scoped-var 1 left) (#%scoped-var 1 right))
      #f)
     (#%scoped-var 1 sum))))))

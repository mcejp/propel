(#%begin
 ((#%defun
   (#%scoped-var 0 factorial)
   ((#%parameter (#%scoped-var 1 n) (#%builtin-type I)))
   (#%builtin-type I)
   (#%begin
    ((#%if
      (#%c++-binary-operator "==" (#%scoped-var 1 n) (#%literal 0))
      (#%literal 1)
      (#%c++-binary-operator
       "*"
       (#%scoped-var 1 n)
       (#%app
        (#%scoped-var 0 factorial)
        ((#%c++-binary-operator "-" (#%scoped-var 1 n) (#%literal 1)))))))))))

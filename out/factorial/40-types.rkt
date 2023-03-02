(#%begin
 ((#%defun
   (#%scoped-var 0 factorial)
   ((#%parameter (#%scoped-var 1 n) (#%builtin-type I)))
   (#%builtin-type I)
   (#%begin
    ((#%if
      (#%app
       (#%scoped-var #f builtin-eq-ii)
       ((#%scoped-var 1 n) (#%literal 0)))
      (#%literal 1)
      (#%app
       (#%scoped-var #f builtin-mul-ii)
       ((#%scoped-var 1 n)
        (#%app
         (#%scoped-var 0 factorial)
         ((#%app
           (#%scoped-var #f builtin-sub-ii)
           ((#%scoped-var 1 n) (#%literal 1)))))))))))))

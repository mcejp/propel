((#%begin
  (#%defun
   factorial
   ((n (#%builtin-type I)))
   (#%builtin-type I)
   (#%begin
    (#%if
     (#%app (#%builtin-function . builtin-eq-ii) (#%scoped-var 2 n) 0)
     1
     (#%app
      (#%builtin-function . builtin-mul-ii)
      (#%scoped-var 2 n)
      (#%app
       (#%scoped-var 1 factorial)
       (#%app (#%builtin-function . builtin-sub-ii) (#%scoped-var 2 n) 1)))))))
 #f
 ((#<path:/workspace/lisp-experiments/propel-syntax.rkt> 46 80 1638 2)
  (#f 0 0 0 2)
  ((#<path:tests/factorial.rkt> -46 -80 -1638 86)
   (#f 0 0 0 86)
   (#f 0 7 7 9)
   ((#f 0 -7 -7 86)
    ((#f 0 0 0 86)
     (#f 0 19 19 1)
     ((#f 0 -19 -19 86) (#f 0 0 0 86) (#f 0 0 0 86))))
   ((#f 0 0 0 86) (#f 0 0 0 86) (#f 0 0 0 86))
   ((#f 0 0 0 86)
    (#f 0 0 0 86)
    ((#f 1 2 33 52)
     (#f 0 0 0 52)
     ((#f 0 4 4 7)
      (#f 0 0 0 7)
      ((#f 0 1 1 1) (#f 0 0 0 1))
      ((#f 0 2 2 1) (#f 0 0 0 1) (#f 0 0 0 1) (#f 0 0 0 1))
      (#f 0 2 2 1))
     (#f 1 -5 9 1)
     ((#f 1 0 8 25)
      (#f 0 0 0 25)
      ((#f 0 1 1 1) (#f 0 0 0 1))
      ((#f 0 2 2 1) (#f 0 0 0 1) (#f 0 0 0 1) (#f 0 0 0 1))
      ((#f 0 2 2 19)
       (#f 0 0 0 19)
       ((#f 0 1 1 9) (#f 0 0 0 9) (#f 0 0 0 9) (#f 0 0 0 9))
       ((#f 0 10 10 7)
        (#f 0 0 0 7)
        ((#f 0 1 1 1) (#f 0 0 0 1))
        ((#f 0 2 2 1) (#f 0 0 0 1) (#f 0 0 0 1) (#f 0 0 0 1))
        (#f 0 2 2 1)))))))))
(#%begin
 ((#%define
   (#%scoped-var 0 board)
   (#%construct
    ((#%literal 0)
     (#%literal 0)
     (#%literal 0)
     (#%literal 0)
     (#%literal 0)
     (#%literal 0)
     (#%literal 0)
     (#%literal 0)
     (#%literal 0)
     (#%literal 0)
     (#%literal 0)
     (#%literal 0)
     (#%literal 0)
     (#%literal 0)
     (#%literal 0)
     (#%literal 0)))
   #t)
  (#%define (#%scoped-var 0 W) (#%literal 4) #f)
  (#%define (#%scoped-var 0 H) (#%literal 4) #f)
  (#%defun
   (#%scoped-var 0 brd-get)
   ((#%parameter (#%scoped-var 1 x) (#%builtin-type I))
    (#%parameter (#%scoped-var 1 y) (#%builtin-type I)))
   (#%builtin-type I)
   (#%begin
    ((#%get
      (#%scoped-var 0 board)
      (#%c++-binary-operator
       "+"
       (#%c++-binary-operator "*" (#%scoped-var 1 y) (#%scoped-var 0 W))
       (#%scoped-var 1 x))))))
  (#%defun
   (#%scoped-var 0 brd-count-empty-spots)
   ()
   (#%builtin-type I)
   (#%begin
    ((#%define (#%scoped-var 2 empty) (#%literal 0) #t)
     (#%begin
      ((#%define (#%scoped-var 2 y) (#%literal 0) #t)
       (#%while
        (#%c++-binary-operator "<" (#%scoped-var 2 y) (#%scoped-var 0 H))
        (#%begin
         ((#%begin
           ((#%define (#%scoped-var 2 x) (#%literal 0) #t)
            (#%while
             (#%c++-binary-operator "<" (#%scoped-var 2 x) (#%scoped-var 0 W))
             (#%begin
              ((#%begin
                ((#%if
                  (#%c++-unary-operator
                   "!"
                   (#%app
                    (#%scoped-var 0 brd-get)
                    ((#%scoped-var 2 x) (#%scoped-var 2 y))))
                  (#%begin
                   ((#%set-var
                     (#%scoped-var 2 empty)
                     (#%c++-binary-operator
                      "+"
                      (#%scoped-var 2 empty)
                      (#%literal 1)))))
                  (#%construct ()))))
               (#%set-var
                (#%scoped-var 2 x)
                (#%c++-binary-operator
                 "+"
                 (#%scoped-var 2 x)
                 (#%literal 1))))))))
          (#%set-var
           (#%scoped-var 2 y)
           (#%c++-binary-operator "+" (#%scoped-var 2 y) (#%literal 1))))))))
     (#%scoped-var 2 empty))))))

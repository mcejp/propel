(#%begin
 ((#%define
   (#%scoped-var 0 get-player-input)
   (#%external-function get-player-input () (#%builtin-type I) #f)
   #f)
  (#%define
   (#%scoped-var 0 random-int)
   (#%external-function
    random-int
    ((#%parameter (#%scoped-var 2 min) (#%builtin-type I))
     (#%parameter (#%scoped-var 2 max) (#%builtin-type I)))
    (#%builtin-type I)
    #f)
   #f)
  (#%define
   (#%scoped-var 0 brd-count-empty-spots)
   (#%external-function brd-count-empty-spots () (#%builtin-type I) #f)
   #f)
  (#%define
   (#%scoped-var 0 brd-get-nth-empty-slot-x)
   (#%external-function
    brd-get-nth-empty-slot-x
    ((#%parameter (#%scoped-var 4 index) (#%builtin-type I)))
    (#%builtin-type I)
    #f)
   #f)
  (#%define
   (#%scoped-var 0 brd-get-nth-empty-slot-y)
   (#%external-function
    brd-get-nth-empty-slot-y
    ((#%parameter (#%scoped-var 5 index) (#%builtin-type I)))
    (#%builtin-type I)
    #f)
   #f)
  (#%define
   (#%scoped-var 0 brd-get-with-rotation)
   (#%external-function
    brd-get-with-rotation
    ((#%parameter (#%scoped-var 6 x) (#%builtin-type I))
     (#%parameter (#%scoped-var 6 y) (#%builtin-type I))
     (#%parameter (#%scoped-var 6 dir) (#%builtin-type I)))
    (#%builtin-type I)
    #f)
   #f)
  (#%define
   (#%scoped-var 0 brd-set-with-rotation)
   (#%external-function
    brd-set-with-rotation
    ((#%parameter (#%scoped-var 7 x) (#%builtin-type I))
     (#%parameter (#%scoped-var 7 y) (#%builtin-type I))
     (#%parameter (#%scoped-var 7 dir) (#%builtin-type I))
     (#%parameter (#%scoped-var 7 stone) (#%builtin-type I)))
    (#%builtin-type V)
    #f)
   #f)
  (#%define (#%scoped-var 0 DIR-LEFT) (#%literal 0) #f)
  (#%defun
   (#%scoped-var 0 brd-set)
   ((#%parameter (#%scoped-var 8 x) (#%builtin-type I))
    (#%parameter (#%scoped-var 8 y) (#%builtin-type I))
    (#%parameter (#%scoped-var 8 value) (#%builtin-type I)))
   (#%builtin-type V)
   (#%begin
    ((#%app
      (#%scoped-var 0 brd-set-with-rotation)
      ((#%scoped-var 8 x)
       (#%scoped-var 8 y)
       (#%scoped-var 0 DIR-LEFT)
       (#%scoped-var 8 value))))))
  (#%defun
   (#%scoped-var 0 and3)
   ((#%parameter (#%scoped-var 9 a) (#%builtin-type I))
    (#%parameter (#%scoped-var 9 b) (#%builtin-type I))
    (#%parameter (#%scoped-var 9 c) (#%builtin-type I)))
   (#%builtin-type I)
   (#%begin
    ((#%c++-binary-operator
      "&&"
      (#%c++-binary-operator "&&" (#%scoped-var 9 a) (#%scoped-var 9 b))
      (#%scoped-var 9 c)))))
  (#%defun
   (#%scoped-var 0 update-row)
   ((#%parameter (#%scoped-var 10 y) (#%builtin-type I))
    (#%parameter (#%scoped-var 10 dir) (#%builtin-type I)))
   (#%builtin-type V)
   (#%begin
    ((#%define (#%scoped-var 10 output-pos) (#%literal 0) #t)
     (#%define (#%scoped-var 10 was-merged) (#%literal 0) #t)
     (#%begin
      ((#%define (#%scoped-var 10 x) (#%literal 0) #t)
       (#%while
        (#%c++-binary-operator "<" (#%scoped-var 10 x) (#%literal 4))
        (#%begin
         ((#%define
           (#%scoped-var 10 stone)
           (#%app
            (#%scoped-var 0 brd-get-with-rotation)
            ((#%scoped-var 10 x) (#%scoped-var 10 y) (#%scoped-var 10 dir)))
           #f)
          (#%begin
           ((#%if
             (#%scoped-var 10 stone)
             (#%begin
              ((#%define
                (#%scoped-var 10 should-merge)
                (#%app
                 (#%scoped-var 0 and3)
                 ((#%c++-binary-operator
                   ">"
                   (#%scoped-var 10 output-pos)
                   (#%literal 0))
                  (#%c++-binary-operator
                   "=="
                   (#%app
                    (#%scoped-var 0 brd-get-with-rotation)
                    ((#%c++-binary-operator
                      "-"
                      (#%scoped-var 10 output-pos)
                      (#%literal 1))
                     (#%scoped-var 10 y)
                     (#%scoped-var 10 dir)))
                   (#%scoped-var 10 stone))
                  (#%c++-unary-operator "!" (#%scoped-var 10 was-merged))))
                #f)
               (#%if
                (#%scoped-var 10 should-merge)
                (#%begin
                 ((#%app
                   (#%scoped-var 0 brd-set-with-rotation)
                   ((#%c++-binary-operator
                     "-"
                     (#%scoped-var 10 output-pos)
                     (#%literal 1))
                    (#%scoped-var 10 y)
                    (#%scoped-var 10 dir)
                    (#%c++-binary-operator
                     "*"
                     (#%literal 2)
                     (#%scoped-var 10 stone))))
                  (#%set-var (#%scoped-var 10 was-merged) (#%literal 1))))
                (#%begin
                 ((#%app
                   (#%scoped-var 0 brd-set-with-rotation)
                   ((#%scoped-var 10 output-pos)
                    (#%scoped-var 10 y)
                    (#%scoped-var 10 dir)
                    (#%scoped-var 10 stone)))
                  (#%set-var (#%scoped-var 10 was-merged) (#%literal 0))
                  (#%set-var
                   (#%scoped-var 10 output-pos)
                   (#%c++-binary-operator
                    "+"
                    (#%scoped-var 10 output-pos)
                    (#%literal 1))))))))
             (#%construct ()))))
          (#%set-var
           (#%scoped-var 10 x)
           (#%c++-binary-operator "+" (#%scoped-var 10 x) (#%literal 1))))))))
     (#%begin
      ((#%define (#%scoped-var 10 columnn) (#%literal 0) #t)
       (#%while
        (#%c++-binary-operator "<" (#%scoped-var 10 columnn) (#%literal 4))
        (#%begin
         ((#%begin
           ((#%if
             (#%c++-binary-operator
              "<="
              (#%scoped-var 10 output-pos)
              (#%scoped-var 10 columnn))
             (#%begin
              ((#%app
                (#%scoped-var 0 brd-set-with-rotation)
                ((#%scoped-var 10 columnn)
                 (#%scoped-var 10 y)
                 (#%scoped-var 10 dir)
                 (#%literal 0)))))
             (#%construct ()))))
          (#%set-var
           (#%scoped-var 10 columnn)
           (#%c++-binary-operator
            "+"
            (#%scoped-var 10 columnn)
            (#%literal 1)))))))))))
  (#%defun
   (#%scoped-var 0 generate-new-stone)
   ()
   (#%builtin-type V)
   (#%begin
    ((#%define
      (#%scoped-var 11 new-stone-value)
      (#%if
       (#%c++-binary-operator
        "<"
        (#%app (#%scoped-var 0 random-int) ((#%literal 0) (#%literal 100)))
        (#%literal 90))
       (#%literal 2)
       (#%literal 4))
      #f)
     (#%define
      (#%scoped-var 11 num-empty-spots)
      (#%app (#%scoped-var 0 brd-count-empty-spots) ())
      #f)
     (#%define
      (#%scoped-var 11 nth-spot)
      (#%app
       (#%scoped-var 0 random-int)
       ((#%literal 0) (#%scoped-var 11 num-empty-spots)))
      #f)
     (#%define
      (#%scoped-var 11 x)
      (#%app
       (#%scoped-var 0 brd-get-nth-empty-slot-x)
       ((#%scoped-var 11 nth-spot)))
      #f)
     (#%define
      (#%scoped-var 11 y)
      (#%app
       (#%scoped-var 0 brd-get-nth-empty-slot-y)
       ((#%scoped-var 11 nth-spot)))
      #f)
     (#%app
      (#%scoped-var 0 brd-set)
      ((#%scoped-var 11 x)
       (#%scoped-var 11 y)
       (#%scoped-var 11 new-stone-value))))))
  (#%defun
   (#%scoped-var 0 make-turn)
   ((#%parameter (#%scoped-var 12 dir) (#%builtin-type I)))
   (#%builtin-type V)
   (#%begin
    ((#%begin
      ((#%define (#%scoped-var 12 row) (#%literal 0) #t)
       (#%while
        (#%c++-binary-operator "<" (#%scoped-var 12 row) (#%literal 4))
        (#%begin
         ((#%app
           (#%scoped-var 0 update-row)
           ((#%scoped-var 12 row) (#%scoped-var 12 dir)))
          (#%set-var
           (#%scoped-var 12 row)
           (#%c++-binary-operator
            "+"
            (#%scoped-var 12 row)
            (#%literal 1)))))))))))))

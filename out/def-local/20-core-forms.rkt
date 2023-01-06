((#%begin
  (#%defun
   add
   ((a int) (b int))
   int
   (#%begin
    (#%define left a)
    (#%define right b)
    (#%define sum (#%app + left right))
    sum)))
 #f
 ((#<path:#INT#/propel-syntax.rkt> 53 95 1969 2)
  (#f 0 0 0 2)
  ((#<path:tests/def-local.rkt> -53 -95 -1969 97)
   (#f 0 0 0 97)
   (#f 0 7 7 3)
   ((#f 0 4 4 17)
    ((#f 0 1 1 7) (#f 0 1 1 1) (#f 0 2 2 3))
    ((#f 0 5 5 7) (#f 0 1 1 1) (#f 0 2 2 3)))
   (#f 0 6 6 3)
   ((#f 0 -29 -29 97)
    (#f 0 0 0 97)
    ((#f 1 2 35 12) (#f 0 0 0 12) (#f 0 5 5 4) (#f 0 5 5 1))
    ((#f 1 -10 5 13) (#f 0 0 0 13) (#f 0 5 5 5) (#f 0 6 6 1))
    ((#f 1 -11 5 24)
     (#f 0 0 0 24)
     (#f 0 5 5 3)
     ((#f 0 4 4 14) (#f 0 0 0 14) (#f 0 1 1 1) (#f 0 2 2 4) (#f 0 5 5 5)))
    (#f 1 -17 10 3)))))

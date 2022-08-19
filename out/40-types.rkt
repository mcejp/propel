((factorial
  ((n int))
  int
  (int
   #%t-begin
   (int
    #%t-if
    (int
     #%t-app
     (#(struct:function-type (int int) int) #%t-builtin-function =)
     ((int #%t-argument n) (int 0)))
    (int 1)
    (int
     #%t-app
     (#(struct:function-type (int int) int) #%t-builtin-function *)
     ((int #%t-argument n)
      (int
       #%t-app
       (#(struct:function-type (int) int) #%t-module-function factorial)
       ((int
         #%t-app
         (#(struct:function-type (int int) int) #%t-builtin-function -)
         ((int #%t-argument n) (int 1)))))))))
  ((#<path:/workspace/lisp-experiments/flyover.rkt> 27 0 503 86)
   (#f 1 2 33 52)
   (#f -1 -2 -33 86)
   ((#f 1 2 33 52)
    (#f 0 0 0 52)
    (#f 0 0 0 52)
    ((#f 0 4 4 7)
     (#f 0 0 0 7)
     (#f 0 0 0 7)
     ((#f 0 1 1 1) (#f 0 0 0 1) (#f 0 0 0 1) (#f 0 0 0 1))
     ((#f 0 -1 -1 7)
      ((#f 0 3 3 1) (#f 0 0 0 1) (#f 0 0 0 1) (#f 0 0 0 1))
      ((#f 0 2 2 1) (#f 0 0 0 1) (#f 0 0 0 1))))
    ((#f 1 -5 9 1) (#f 0 0 0 1) (#f 0 0 0 1))
    ((#f 1 0 8 25)
     (#f 0 0 0 25)
     (#f 0 0 0 25)
     ((#f 0 1 1 1) (#f 0 0 0 1) (#f 0 0 0 1) (#f 0 0 0 1))
     ((#f 0 -1 -1 25)
      ((#f 0 3 3 1) (#f 0 0 0 1) (#f 0 0 0 1) (#f 0 0 0 1))
      ((#f 0 2 2 19)
       (#f 0 0 0 19)
       (#f 0 0 0 19)
       ((#f 0 1 1 9) (#f 0 0 0 9) (#f 0 0 0 9) (#f 0 0 0 9))
       ((#f 0 -1 -1 19)
        ((#f 0 11 11 7)
         (#f 0 0 0 7)
         (#f 0 0 0 7)
         ((#f 0 1 1 1) (#f 0 0 0 1) (#f 0 0 0 1) (#f 0 0 0 1))
         ((#f 0 -1 -1 7)
          ((#f 0 3 3 1) (#f 0 0 0 1) (#f 0 0 0 1) (#f 0 0 0 1))
          ((#f 0 2 2 1) (#f 0 0 0 1) (#f 0 0 0 1))))))))))))

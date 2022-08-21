((factorial
  ((n int))
  int
  (#%begin
   (#%if
    (#%app (#%builtin-function . =) (#%argument . n) 0)
    1
    (#%app
     (#%builtin-function . *)
     (#%argument . n)
     (#%app
      (#%module-function . factorial)
      (#%app (#%builtin-function . -) (#%argument . n) 1)))))
  (int
   (int
    (int (#(struct:function-type (int int) int) . #f) (int . #f) (int . #f))
    (int . #f)
    (int
     (#(struct:function-type (int int) int) . #f)
     (int . #f)
     (int
      (#(struct:function-type (int) int) . #f)
      (int
       (#(struct:function-type (int int) int) . #f)
       (int . #f)
       (int . #f))))))
  ((#<path:/workspace/lisp-experiments/flyover.rkt> 27 0 503 86)
   (#f 0 0 0 86)
   ((#f 1 2 33 52)
    (#f 0 0 0 52)
    ((#f 0 4 4 7)
     (#f 0 0 0 7)
     ((#f 0 1 1 1) (#f 0 0 0 1))
     ((#f 0 2 2 1) (#f 0 0 0 1))
     (#f 0 2 2 1))
    (#f 1 -5 9 1)
    ((#f 1 0 8 25)
     (#f 0 0 0 25)
     ((#f 0 1 1 1) (#f 0 0 0 1))
     ((#f 0 2 2 1) (#f 0 0 0 1))
     ((#f 0 2 2 19)
      (#f 0 0 0 19)
      ((#f 0 1 1 9) (#f 0 0 0 9))
      ((#f 0 10 10 7)
       (#f 0 0 0 7)
       ((#f 0 1 1 1) (#f 0 0 0 1))
       ((#f 0 2 2 1) (#f 0 0 0 1))
       (#f 0 2 2 1))))))))

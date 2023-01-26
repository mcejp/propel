((begin
   (var
    board
    (#%construct (#%array-type int 16) 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0))
   (def W 4)
   (def H 4)
   (defun brd-get ((x int) (y int)) int (get board (+ (* y W) x)))
   (defun
    brd-count-empty-spots
    ()
    int
    (var empty 0)
    (begin
      (var y 0)
      (while
       (< y H)
       (begin
         (begin
           (var x 0)
           (while
            (< x W)
            (begin
              (begin
                (if (not (brd-get x y))
                  (begin (set! empty (+ empty 1)))
                  (Void)))
              (set! x (+ x 1)))))
         (set! y (+ y 1)))))
    empty))
 #f
 ((#<path:tests/2048-board.rkt> 0 0 0 481)
  (#f 0 0 0 481)
  ((#f 2 0 43 181)
   (#f 0 1 1 3)
   (#f 0 4 4 5)
   ((#f 0 6 6 169)
    (#f 0 0 0 169)
    ((#f 0 0 0 169) (#f 0 0 0 169) (#f 0 22 22 3) (#f 0 -22 -22 169))
    (#f 0 26 26 1)
    (#f 0 2 2 1)
    (#f 0 2 2 1)
    (#f 0 2 2 1)
    (#f 1 -6 39 1)
    (#f 0 2 2 1)
    (#f 0 2 2 1)
    (#f 0 2 2 1)
    (#f 1 -6 39 1)
    (#f 0 2 2 1)
    (#f 0 2 2 1)
    (#f 0 2 2 1)
    (#f 1 -6 39 1)
    (#f 0 2 2 1)
    (#f 0 2 2 1)
    (#f 0 2 2 1)))
  ((#f 2 -43 5 9) (#f 0 1 1 3) (#f 0 4 4 1) (#f 0 2 2 1))
  ((#f 1 -7 3 9) (#f 0 1 1 3) (#f 0 4 4 1) (#f 0 2 2 1))
  ((#f 2 -7 4 65)
   (#f 0 1 1 5)
   (#f 0 6 6 7)
   ((#f 0 8 8 17)
    ((#f 0 1 1 7) (#f 0 1 1 1) (#f 0 2 2 3))
    ((#f 0 5 5 7) (#f 0 1 1 1) (#f 0 2 2 3)))
   (#f 0 6 6 3)
   ((#f 1 -31 6 25)
    (#f 0 1 1 3)
    (#f 0 4 4 5)
    ((#f 0 6 6 13)
     (#f 0 1 1 1)
     ((#f 0 2 2 7) (#f 0 1 1 1) (#f 0 2 2 1) (#f 0 2 2 1))
     (#f 0 3 3 1))))
  ((#f 2 -24 6 166)
   (#f 0 1 1 5)
   (#f 0 6 6 21)
   ((#f 0 22 22 2))
   (#f 0 3 3 3)
   ((#f 1 -30 6 13) (#f 0 1 1 3) (#f 0 4 4 5) (#f 0 6 6 1))
   ((#f 2 -11 6 101)
    (#f 0 0 0 101)
    ((#f 0 0 0 101) (#f 0 0 0 101) (#f 0 11 11 1) (#f 0 -11 -11 101))
    ((#f 0 0 0 101)
     (#f 0 0 0 101)
     ((#f 0 0 0 101) (#f 0 0 0 101) (#f 0 11 11 1) (#f 0 2 2 1))
     ((#f 0 -13 -13 101)
      (#f 0 0 0 101)
      ((#f 1 2 19 81)
       (#f 0 0 0 81)
       ((#f 0 0 0 81) (#f 0 0 0 81) (#f 0 11 11 1) (#f 0 -11 -11 81))
       ((#f 0 0 0 81)
        (#f 0 0 0 81)
        ((#f 0 0 0 81) (#f 0 0 0 81) (#f 0 11 11 1) (#f 0 2 2 1))
        ((#f 0 -13 -13 81)
         (#f 0 0 0 81)
         ((#<path:propel-builtins.rkt> 38 3 1182 72)
          (#f 0 1 1 5)
          ((#f 1 1 15 55)
           (#f 0 1 1 2)
           ((#<path:tests/2048-board.rkt> -38 2 -1172 19)
            (#f 0 1 1 3)
            ((#f 0 4 4 13) (#f 0 1 1 7) (#f 0 8 8 1) (#f 0 2 2 1)))
           ((#<path:propel-builtins.rkt> 39 -17 1175 16)
            (#f 0 1 1 5)
            ((#<path:tests/2048-board.rkt> -38 -4 -1164 24)
             (#f 0 1 1 4)
             (#f 0 5 5 5)
             ((#f 0 6 6 11) (#f 0 1 1 1) (#f 0 2 2 5) (#f 0 6 6 1))))
           ((#<path:propel-builtins.rkt> 39 -18 1170 6) (#f 0 1 1 4))))
         ((#<path:tests/2048-board.rkt> -41 -8 -1247 81)
          (#f 0 0 0 81)
          (#f 0 11 11 1)
          ((#f 0 -11 -11 81)
           (#f 0 0 0 81)
           (#f 0 11 11 1)
           (#f 0 -11 -11 81))))))
      ((#f -1 -2 -19 101)
       (#f 0 0 0 101)
       (#f 0 11 11 1)
       ((#f 0 -11 -11 101)
        (#f 0 0 0 101)
        (#f 0 11 11 1)
        (#f 0 -11 -11 101))))))
   (#f 5 0 105 5))))
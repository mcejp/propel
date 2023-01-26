((begin
   (def get-player-input (#%external-function get-player-input () int))
   (def random-int (#%external-function random-int ((min int) (max int)) int))
   (def
    brd-count-empty-spots
    (#%external-function brd-count-empty-spots () int))
   (def
    brd-get-nth-empty-slot-x
    (#%external-function brd-get-nth-empty-slot-x ((index int)) int))
   (def
    brd-get-nth-empty-slot-y
    (#%external-function brd-get-nth-empty-slot-y ((index int)) int))
   (def
    brd-get-with-rotation
    (#%external-function
     brd-get-with-rotation
     ((x int) (y int) (dir int))
     int))
   (def
    brd-set-with-rotation
    (#%external-function
     brd-set-with-rotation
     ((x int) (y int) (dir int) (stone int))
     Void))
   (def DIR-LEFT 0)
   (defun
    brd-set
    ((x int) (y int) (value int))
    Void
    (brd-set-with-rotation x y DIR-LEFT value))
   (defun and3 ((a int) (b int) (c int)) int (and (and a b) c))
   (defun
    update-row
    ((y int) (dir int))
    Void
    (var output-pos 0)
    (var was-merged 0)
    (begin
      (var x 0)
      (while
       (< x 4)
       (begin
         (def stone (brd-get-with-rotation x y dir))
         (begin
           (if stone
             (begin
               (def
                should-merge
                (and3
                 (> output-pos 0)
                 (= (brd-get-with-rotation (- output-pos 1) y dir) stone)
                 (not was-merged)))
               (if should-merge
                 (begin
                   (brd-set-with-rotation (- output-pos 1) y dir (* 2 stone))
                   (set! was-merged 1))
                 (begin
                   (brd-set-with-rotation output-pos y dir stone)
                   (set! was-merged 0)
                   (set! output-pos (+ output-pos 1)))))
             (Void)))
         (set! x (+ x 1)))))
    (begin
      (var columnn 0)
      (while
       (< columnn 4)
       (begin
         (begin
           (if (<= output-pos columnn)
             (begin (brd-set-with-rotation columnn y dir 0))
             (Void)))
         (set! columnn (+ columnn 1))))))
   (defun
    generate-new-stone
    ()
    Void
    (def new-stone-value (if (< (random-int 0 100) 90) 2 4))
    (def num-empty-spots (brd-count-empty-spots))
    (def nth-spot (random-int 0 num-empty-spots))
    (def x (brd-get-nth-empty-slot-x nth-spot))
    (def y (brd-get-nth-empty-slot-y nth-spot))
    (brd-set x y new-stone-value))
   (defun
    make-turn
    ((dir int))
    Void
    (begin
      (var row 0)
      (while (< row 4) (begin (update-row row dir) (set! row (+ row 1)))))))
 #f
 ((#<path:tests/2048.rkt> 0 0 0 4075)
  (#f 0 0 0 4075)
  ((#<path:propel-builtins.rkt> 8 7 262 46)
   (#f 0 1 1 3)
   (#<path:tests/2048.rkt> 4 11 -11 16)
   ((#<path:propel-builtins.rkt> -4 -2 20 35)
    (#f 0 1 1 19)
    (#<path:tests/2048.rkt> 4 1 -21 16)
    ((#f 0 17 17 2))
    (#f 0 3 3 3)))
  ((#<path:propel-builtins.rkt> -4 -32 -10 46)
   (#f 0 1 1 3)
   (#<path:tests/2048.rkt> 5 11 33 10)
   ((#<path:propel-builtins.rkt> -5 -2 -24 35)
    (#f 0 1 1 19)
    (#<path:tests/2048.rkt> 5 1 23 10)
    ((#f 0 11 11 21)
     ((#f 0 1 1 9) (#f 0 1 1 3) (#f 0 4 4 3))
     ((#f 0 5 5 9) (#f 0 1 1 3) (#f 0 4 4 3)))
    (#f 0 6 6 3)))
  ((#<path:propel-builtins.rkt> -5 -45 -67 46)
   (#f 0 1 1 3)
   (#<path:tests/2048.rkt> 9 11 184 21)
   ((#<path:propel-builtins.rkt> -9 -2 -175 35)
    (#f 0 1 1 19)
    (#<path:tests/2048.rkt> 9 1 174 21)
    ((#f 0 22 22 2))
    (#f 0 3 3 3)))
  ((#<path:propel-builtins.rkt> -9 -37 -210 46)
   (#f 0 1 1 3)
   (#<path:tests/2048.rkt> 10 11 233 24)
   ((#<path:propel-builtins.rkt> -10 -2 -224 35)
    (#f 0 1 1 19)
    (#<path:tests/2048.rkt> 10 1 223 24)
    ((#f 0 25 25 13) ((#f 0 1 1 11) (#f 0 1 1 5) (#f 0 6 6 3)))
    (#f 0 6 6 3)))
  ((#<path:propel-builtins.rkt> -10 -51 -273 46)
   (#f 0 1 1 3)
   (#<path:tests/2048.rkt> 11 11 296 24)
   ((#<path:propel-builtins.rkt> -11 -2 -287 35)
    (#f 0 1 1 19)
    (#<path:tests/2048.rkt> 11 1 286 24)
    ((#f 0 25 25 13) ((#f 0 1 1 11) (#f 0 1 1 5) (#f 0 6 6 3)))
    (#f 0 6 6 3)))
  ((#<path:propel-builtins.rkt> -11 -51 -336 46)
   (#f 0 1 1 3)
   (#<path:tests/2048.rkt> 12 11 359 21)
   ((#<path:propel-builtins.rkt> -12 -2 -350 35)
    (#f 0 1 1 19)
    (#<path:tests/2048.rkt> 12 1 349 21)
    ((#f 0 22 22 27)
     ((#f 0 1 1 7) (#f 0 1 1 1) (#f 0 2 2 3))
     ((#f 0 5 5 7) (#f 0 1 1 1) (#f 0 2 2 3))
     ((#f 0 5 5 9) (#f 0 1 1 3) (#f 0 4 4 3)))
    (#f 0 6 6 3)))
  ((#<path:propel-builtins.rkt> -12 -62 -410 46)
   (#f 0 1 1 3)
   (#<path:tests/2048.rkt> 13 11 433 21)
   ((#<path:propel-builtins.rkt> -13 -2 -424 35)
    (#f 0 1 1 19)
    (#<path:tests/2048.rkt> 13 1 423 21)
    ((#f 0 22 22 39)
     ((#f 0 1 1 7) (#f 0 1 1 1) (#f 0 2 2 3))
     ((#f 0 5 5 7) (#f 0 1 1 1) (#f 0 2 2 3))
     ((#f 0 5 5 9) (#f 0 1 1 3) (#f 0 4 4 3))
     ((#f 0 5 5 11) (#f 0 1 1 5) (#f 0 6 6 3)))
    (#f 0 6 6 4)))
  ((#f 2 -81 7 16) (#f 0 1 1 3) (#f 0 4 4 8) (#f 0 9 9 1))
  ((#f 2 -14 4 95)
   (#f 0 1 1 5)
   (#f 0 6 6 7)
   ((#f 0 8 8 29)
    ((#f 0 1 1 7) (#f 0 1 1 1) (#f 0 2 2 3))
    ((#f 0 5 5 7) (#f 0 1 1 1) (#f 0 2 2 3))
    ((#f 0 5 5 11) (#f 0 1 1 5) (#f 0 6 6 3)))
   (#f 0 6 6 4)
   ((#f 1 -43 7 42)
    (#f 0 1 1 21)
    (#f 0 22 22 1)
    (#f 0 2 2 1)
    (#f 0 2 2 8)
    (#f 0 9 9 5)))
  ((#f 3 -38 38 62)
   (#f 0 1 1 5)
   (#f 0 6 6 4)
   ((#f 0 5 5 25)
    ((#f 0 1 1 7) (#f 0 1 1 1) (#f 0 2 2 3))
    ((#f 0 5 5 7) (#f 0 1 1 1) (#f 0 2 2 3))
    ((#f 0 5 5 7) (#f 0 1 1 1) (#f 0 2 2 3)))
   (#f 0 6 6 3)
   ((#f 1 -36 6 17)
    (#f 0 1 1 3)
    ((#f 0 4 4 9) (#f 0 1 1 3) (#f 0 4 4 1) (#f 0 2 2 1))
    (#f 0 3 3 1)))
  ((#f 3 -17 65 1029)
   (#f 0 1 1 5)
   (#f 0 6 6 10)
   ((#f 0 11 11 19)
    ((#f 0 1 1 7) (#f 0 1 1 1) (#f 0 2 2 3))
    ((#f 0 5 5 9) (#f 0 1 1 3) (#f 0 4 4 3)))
   (#f 0 6 6 4)
   ((#f 3 -36 64 18) (#f 0 1 1 3) (#f 0 4 4 10) (#f 0 11 11 1))
   ((#f 1 -16 5 18) (#f 0 1 1 3) (#f 0 4 4 10) (#f 0 11 11 1))
   ((#f 2 -16 6 776)
    (#f 0 0 0 776)
    ((#f 0 0 0 776) (#f 0 0 0 776) (#f 0 11 11 1) (#f 0 -11 -11 776))
    ((#f 0 0 0 776)
     (#f 0 0 0 776)
     ((#f 0 0 0 776) (#f 0 0 0 776) (#f 0 11 11 1) (#f 0 2 2 1))
     ((#f 0 -13 -13 776)
      (#f 0 0 0 776)
      ((#f 2 2 64 43)
       (#f 0 1 1 3)
       (#f 0 4 4 5)
       ((#f 0 6 6 31) (#f 0 1 1 21) (#f 0 22 22 1) (#f 0 2 2 1) (#f 0 2 2 3)))
      ((#<path:propel-builtins.rkt> 14 -35 290 72)
       (#f 0 1 1 5)
       ((#f 1 1 15 55)
        (#f 0 1 1 2)
        (#<path:tests/2048.rkt> -14 0 -291 5)
        ((#<path:propel-builtins.rkt> 15 1 310 16)
         (#f 0 1 1 5)
         ((#<path:tests/2048.rkt> -13 -6 -183 176)
          (#f 0 1 1 3)
          (#f 0 4 4 12)
          ((#f 0 13 13 157)
           (#f 0 1 1 4)
           ((#f 0 5 5 16) (#f 0 1 1 1) (#f 0 2 2 10) (#f 0 11 11 1))
           ((#f 1 -14 33 56)
            (#f 0 1 1 1)
            ((#f 0 2 2 46)
             (#f 0 1 1 21)
             ((#f 0 22 22 16) (#f 0 1 1 1) (#f 0 2 2 10) (#f 0 11 11 1))
             (#f 0 3 3 1)
             (#f 0 2 2 3))
            (#f 0 5 5 5))
           ((#f 1 -50 37 16) (#f 0 1 1 3) (#f 0 4 4 10))))
         ((#f 2 -29 51 307)
          (#f 0 1 1 2)
          (#f 0 3 3 12)
          ((#f 1 -2 21 115)
           (#f 0 1 1 5)
           ((#f 1 1 16 58)
            (#f 0 1 1 21)
            ((#f 0 22 22 16) (#f 0 1 1 1) (#f 0 2 2 10) (#f 0 11 11 1))
            (#f 0 3 3 1)
            (#f 0 2 2 3)
            ((#f 0 4 4 11) (#f 0 1 1 1) (#f 0 2 2 1) (#f 0 2 2 5)))
           ((#f 1 -51 18 19) (#f 0 1 1 4) (#f 0 5 5 10) (#f 0 11 11 1)))
          ((#f 2 -19 21 148)
           (#f 0 1 1 5)
           ((#f 1 1 16 46)
            (#f 0 1 1 21)
            (#f 0 22 22 10)
            (#f 0 11 11 1)
            (#f 0 2 2 3)
            (#f 0 4 4 5))
           ((#f 1 -40 17 19) (#f 0 1 1 4) (#f 0 5 5 10) (#f 0 11 11 1))
           ((#f 1 -17 13 34)
            (#f 0 1 1 4)
            (#f 0 5 5 10)
            ((#f 0 11 11 16) (#f 0 1 1 1) (#f 0 2 2 10) (#f 0 11 11 1))))))
        ((#<path:propel-builtins.rkt> 2 -30 -288 6) (#f 0 1 1 4))))
      ((#<path:tests/2048.rkt> -19 -10 -457 776)
       (#f 0 0 0 776)
       (#f 0 11 11 1)
       ((#f 0 -11 -11 776)
        (#f 0 0 0 776)
        (#f 0 11 11 1)
        (#f 0 -11 -11 776))))))
   ((#f 22 0 780 102)
    (#f 0 0 0 102)
    ((#f 0 0 0 102) (#f 0 0 0 102) (#f 0 11 11 7) (#f 0 -11 -11 102))
    ((#f 0 0 0 102)
     (#f 0 0 0 102)
     ((#f 0 0 0 102) (#f 0 0 0 102) (#f 0 11 11 7) (#f 0 8 8 1))
     ((#f 0 -19 -19 102)
      (#f 0 0 0 102)
      ((#<path:propel-builtins.rkt> -6 5 -388 72)
       (#f 0 1 1 5)
       ((#f 1 1 15 55)
        (#f 0 1 1 2)
        ((#<path:tests/2048.rkt> 6 0 402 23)
         (#f 0 1 1 2)
         (#f 0 3 3 10)
         (#f 0 11 11 7))
        ((#<path:propel-builtins.rkt> -5 -14 -398 16)
         (#f 0 1 1 5)
         ((#<path:tests/2048.rkt> 6 -6 412 39)
          (#f 0 1 1 21)
          (#f 0 22 22 7)
          (#f 0 8 8 1)
          (#f 0 2 2 3)
          (#f 0 4 4 1)))
        ((#<path:propel-builtins.rkt> -5 -32 -422 6) (#f 0 1 1 4))))
      ((#<path:tests/2048.rkt> 3 -10 323 102)
       (#f 0 0 0 102)
       (#f 0 11 11 7)
       ((#f 0 -11 -11 102)
        (#f 0 0 0 102)
        (#f 0 11 11 7)
        (#f 0 -11 -11 102)))))))
  ((#f 5 -2 106 736)
   (#f 0 1 1 5)
   (#f 0 6 6 18)
   ((#f 0 19 19 2))
   (#f 0 3 3 4)
   ((#f 2 -27 65 56)
    (#f 0 1 1 3)
    (#f 0 4 4 15)
    ((#f 0 16 16 34)
     (#f 0 1 1 2)
     ((#f 0 3 3 25)
      (#f 0 1 1 1)
      ((#f 0 2 2 18) (#f 0 1 1 10) (#f 0 11 11 1) (#f 0 2 2 3))
      (#f 0 5 5 2))
     (#f 0 4 4 1)
     (#f 0 2 2 1)))
   ((#f 3 -53 98 45)
    (#f 0 1 1 3)
    (#f 0 4 4 15)
    ((#f 0 16 16 23) (#f 0 1 1 21)))
   ((#f 2 -22 60 45)
    (#f 0 1 1 3)
    (#f 0 4 4 8)
    ((#f 0 9 9 30) (#f 0 1 1 10) (#f 0 11 11 1) (#f 0 2 2 15)))
   ((#f 2 -28 99 43)
    (#f 0 1 1 3)
    (#f 0 4 4 1)
    ((#f 0 2 2 35) (#f 0 1 1 24) (#f 0 25 25 8)))
   ((#f 1 -33 13 43)
    (#f 0 1 1 3)
    (#f 0 4 4 1)
    ((#f 0 2 2 35) (#f 0 1 1 24) (#f 0 25 25 8)))
   ((#f 2 -33 68 29) (#f 0 1 1 7) (#f 0 8 8 1) (#f 0 2 2 1) (#f 0 2 2 15)))
  ((#f 6 -15 124 1272)
   (#f 0 1 1 5)
   (#f 0 6 6 9)
   ((#f 0 10 10 11) ((#f 0 1 1 9) (#f 0 1 1 3) (#f 0 4 4 3)))
   (#f 0 6 6 4)
   ((#f 29 -27 1115 42)
    (#f 0 0 0 42)
    ((#f 0 0 0 42) (#f 0 0 0 42) (#f 0 11 11 3) (#f 0 -11 -11 42))
    ((#f 0 0 0 42)
     (#f 0 0 0 42)
     ((#f 0 0 0 42) (#f 0 0 0 42) (#f 0 11 11 3) (#f 0 4 4 1))
     ((#f 0 -15 -15 42)
      (#f 0 0 0 42)
      ((#f 1 2 21 20) (#f 0 1 1 10) (#f 0 11 11 3) (#f 0 4 4 3))
      ((#f -1 -18 -37 42)
       (#f 0 0 0 42)
       (#f 0 11 11 3)
       ((#f 0 -11 -11 42)
        (#f 0 0 0 42)
        (#f 0 11 11 3)
        (#f 0 -11 -11 42)))))))))
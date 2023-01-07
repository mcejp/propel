;; 4 rows x 4 columns
;(deftype Board (array I 4 4))
;(defvar the-board (Board))

; (defun count-empty-spots ([b (pointer Board)]) I
;   TODO
; )

; (defun get-nth-empty-slot ([b (pointer Board)] [index I]) (tuple I I)
;   TODO
; )

(decl-external-fun get-player-input () int)
(decl-external-fun random-int ((min int) (max int)) int)

;; Since we don't have arrays yet, we have to rely on a number of external helper functions

(decl-external-fun brd-count-empty-spots () int)
(decl-external-fun brd-get-nth-empty-slot-x ((index int)) int)
(decl-external-fun brd-get-nth-empty-slot-y ((index int)) int)
(decl-external-fun brd-get-with-rotation ((x int) (y int) (dir int)) int)
(decl-external-fun brd-set-with-rotation ((x int) (y int) (dir int) (stone int)) Void)

(decl-external-fun is-marked-merged ((pos int)) int)
(decl-external-fun mark-merged ((pos int) (value int)) Void)

(def DIR-LEFT 0)

(defun brd-set ((x int) (y int) (value int)) Void
  (brd-set-with-rotation x y DIR-LEFT value))

;; Note: no short-circuiting
(defun and3 ((a int) (b int) (c int)) int
  (and (and a b) c))

;; return new output-pos
(defun update-column ((x int) (y int) (dir int) (output-pos int)) int
  ;; check if any stone in source position
  (def stone (brd-get-with-rotation x y dir))
  (if stone (begin
    ;; check if should be merged -- output is non-empty, last stone is identical and is not the result of a merge
    (def should-merge (and3 (> output-pos 0)
                            (= (brd-get-with-rotation (- output-pos 1) y dir) stone)
                            (not (is-marked-merged (- output-pos 1)))))
    ;; put into output array
    (if should-merge
      (begin
        (brd-set-with-rotation (- output-pos 1) y dir (* 2 stone))
        (mark-merged (- output-pos 1) 1)
        output-pos
      )
      (begin
        (brd-set-with-rotation output-pos y dir stone)
        (mark-merged output-pos 0)
        (+ output-pos 1)
      )
    ))
    output-pos
  )
)

;; assume move direction is LEFT, fix up at the last moment
(defun update-row ((y int) (dir int)) Void
  ;; iterate row from the left, merging un-merged cells

  (def output-pos 0)

  (for/range column 4
    (set! output-pos (update-column column y dir output-pos)))

  (for/range columnn 4
    (when (<= output-pos columnn)
      (brd-set-with-rotation columnn y dir 0)))
)

(defun generate-new-stone () Void
  ;; better: (def new-stone-value (random-choice '(2 4)))
  (def new-stone-value (if (< (random-int 0 100) 90) 2 4))
  ;; count empty spots
  ;; better: (def num-empty-spots (count-empty-spots (& the-board)))
  (def num-empty-spots (brd-count-empty-spots))
  ; ;; place stone at random spot
  (def nth-spot (random-int 0 num-empty-spots))
  ;; better: (unpack-define (x y) (get-nth-empty-slot (& the-board) nth-spot))
  (def x (brd-get-nth-empty-slot-x nth-spot))
  (def y (brd-get-nth-empty-slot-y nth-spot))
  ;; better: (set! ([] the-board y x) new-stone-value)
  (brd-set x y new-stone-value)
  ;(animate-stone-placement x y new-stone-value)

  ;; TODO: check if valid move exists, else game over
)

(defun make-turn ((dir int)) Void
  ;; wait for player to choose movement direction
  ;(def dir (get-player-input))

  ;; TODO: check if move valid

  ;; go over rows/columns (orthogonal to player move) and update each separately
  ; (for ([row-or-column (range 0 4)])
  ;     ;; relevant-stones :: (list (tuple x y value) ...)
  ;     (defvar relevant-stones (extract-stones (& the-board) dir row-or-column))
  ;     (defvar new-list-of-stones '())
  ;     ;; iterate backwards, always remembering previously seen stone
  ;     (defvar last-stone null (tuple I I I))
  ;     (for ([i (range (len relevant-stones) -1 -1)])
  ;         (if (last-stone && current-stone == last-stone)
  ;             (remove last from new-list-of-stones + cancel animation or not?)
  ;             (merge current, last, new-pos) => new-list-of-stones
  ;             animate merge
  ;             last = none ; nothing can merge into this
  ;         )
  ;         else (
  ;             (current -> new-list-of-stones)
  ;             animate move
  ;             (last = current)
  ;         )
  ;     )
  ;     (update-board-with new-list-of-stones)
  ; )

  (for/range row 4
    (update-row row dir))

  ;; TODO: can check if any movement made, if not, jump back to (get-player-input)
)

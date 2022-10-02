(defun factorial ((n int)) int
  (if (= n 0)
      1
      (* n (factorial (- n 1)))))

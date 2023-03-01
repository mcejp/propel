(decl-external-fun bar () int)
(decl-external-fun warn () Void)

(defun main ((baz int)) Void
  (def foo (+
    (bar)
    (if baz
        1
        (begin
          (warn)
          2)))
    ))

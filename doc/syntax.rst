Syntax elements
===============

Arrays (partially implemented)::

  (deftype Board-2D (array I 4 4))

  ;; explicitly sized without bothering to 'deftype' it
  (def my-array ((array B 3) 0x10 0x20 0x30))

  ;; implicitly sized
  (def my-array (make-array-with-type B 0x10 0x20 0x30))

  (def my-length (len my-array))


Iteration::

  ;; not possible yet
  (for ([i (range 0 10)])
    body
    ...
    )

  (for/range i 10
    body
    ...
    )


Structs::

Transformers (macros)::

  (define-transformer emit-palette-array (lambda (filename)
    (define the-palette (list 1 2 3 4))
    `(def my-palette (make-array-with-type B ,@the-palette))
    ))

  (emit-palette-array "dummy.pal")


Void / void type::

  (begin
    (print "Hello")
    (Void)
    (Void)
    (if #t (Void) (Void))

    ;; in the future, simply:
    void
    )

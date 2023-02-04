Syntax elements
===============

Arrays
------
.. code-block::

  (def array (make-array-with-type int 1 2 3))

  (def my-length (len my-array))
  (def item (get my-array 1))

  ;; code below doesn't work, only 1D arrays are implemented

  (deftype Board-2D (array I 4 4))

  ;; implicitly sized
  (def my-array (make-array-with-type B 0x10 0x20 0x30))


Iteration
---------
.. code-block::

  (def array (make-array-with-type int 1 2 3))
  (for ([i array])
    body
    ...
    )

  (for/range i 10
    body
    ...
    )

  ;; not possible yet
  (for ([i (range 0 10)])
    body
    ...
    )


Macros
------
.. code-block::

  (define-transformer emit-palette-array (lambda (name)
    (define the-palette (list 1 2 3 4))
    `(def ,name (make-array-with-type int ,@the-palette))
    ))

  (emit-palette-array my-palette)


Modules
-------

(not implemented yet)

.. code-block::

  ;; like in Racket

  ;; mod1.rkt
  (require mod2)

  (defun main () Void
    (foo))

  ;; mod2.rkt
  (provide foo)

  (defun foo () Void
    (print "Hello world"))

This will work by first expanding all macros (eugh), then scanning the module for exports and their types.


Structs
-------


Void
----
.. code-block::

  (begin
    (print "Hello")
    (Void)
    (Void)
    (if #t (Void) (Void))

    ;; in the future, simply:
    void
    )

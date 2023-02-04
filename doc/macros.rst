Macro language and environment
==============================

Definition and usage
--------------------
A macro is defined using the ``define-transformer`` form, specified with a name and the transformer function.
The transformer function is a Racket expression which is evaluated immediately, at compile time.
Normally, this will be a ``lambda`` form.

Whenever the macro is used, the transformer receives the arguments specified at the usage site.
Note that these are syntax objects. They can represent Propel code, Racket code, or an arbitrary other language --
it is entirely up to the transformer to interpret them (though they must parse as valid S-expressions).

.. code-block::

  (define-transformer emit-palette-array (lambda (name)
    (define the-palette (list 1 2 3 4))
    `(def ,name (make-array-with-type int ,@the-palette))
    ))

  (emit-palette-array my-palette)


Macro namespace
---------------
Macros execute in a *macro namespace* which is private to each Propel module. ``racket/base`` can be assumed to be available.


Importing other modules
-----------------------
Use ``(for-syntax (require ...))`` at the top level. Relative requires are resolved relative to the directory containing the source file.


Loading files
-------------
Build systems need to be aware of a source file's transitive dependencies.
To this end, an explicit function should be provided as a substitute for ``open-input-file`` et al.

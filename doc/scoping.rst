Scoping
=======

The scoping model should be very similar to that of C/C++, so for example an ``if``-form should introduce a new scope
(unlike in Scheme/Racket). In fact, doesn't *every form* other than ``begin`` introduce a new scope?
(``begin`` needs to be transparent to allow macros to emit multiple forms inline)

Scopes are nested and ultimately inherit from a built-in unmodifiable *base scope*.

A new scope is introduced by:

- a Propel module
- a function definition body

That's right -- there is currently no form that would introduce a nested scope inside a function body.
(this is obviously broken since it doesn't match what happens in the generated C++)

Scopes are **not** explicitly represented in the syntax tree and each pass needs to be aware of them.
(it's not entirely easy, as for example function arguments need to be inserted into a scope that is at a deeper level in the AST)

At the moment functions cannot call functions declared later in the module -- this also precludes mutual recursion.
It would be very desirable to have this possibility. It will presumably require making two passes over the module,
first populating the scope with correctly typed placeholders (whoa -- this might be non-trivial)

An easy workaround might be to require the use of a special forward-declaration form for the moment.

Variables and types live in separate namespaces.

Some inspiration: https://en.cppreference.com/w/cpp/language/scope (nicely illustrates some of the complex edge-cases too)

TODO: How can we rigorously ensure that our scoping model, as implemented in propel-names.rkt, matches that of the generated C++ code?

Plain symbols vs dedicated form
-------------------------------

Using plain symbols after the name resolution step would be nice, but are good reasons for having a structured form:

- we should preserve information about scope boundaries, it might come in handy at some point
- back-ends need to detect symbols coming from certain scopes (built-ins and module-level)

Thus we emit the following forms::

  (#%scope 1234 (x y z)
    ...
    (#%scoped-var 1234 x)
    (#%scoped-var 1234 y)
    ...)

  ;; a scope ID of #f is used for built-ins
  (#%app
    (#%scoped-var #f print)
    ...)

The naming resolution step has extra logic to omit useless scopes (those that do not add any symbols).

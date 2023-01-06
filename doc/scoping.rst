Scoping
=======

The scoping model should be very similar to that of C/C++, so for example an ``if``-form should introduce a new scope
(unlike in Scheme/Racket).

Scopes are nested and ultimately inherit from a built-in unmodifiable *base scope*.

A new scope is introduced by:

- a Propel module
- a function definition body

That's right -- there is currently no form that would introduce a nested scope inside a function body.

Scopes are **not** explicitly represented in the syntax tree and each pass needs to be aware of them.
(it's not entirely easy, as for example function arguments need to be inserted into a scope that is at a deeper level in the AST)

Functions cannot call functions declared later in the module (right?). This would be desirable and Scheme has already solved it.

Core forms
==========

(work in progress)

- ``(#%app <func> <args>...*)``
- ``(#%begin <stmt> ...+)``
- ``(#%construct <type> <args>...*)``
- ``(#%dot <expr> <name>)``
- ``(#%if <expr> <then> <else>)``
- ``(#%len <expr>)`` (would be nice if this could be librarized. evaluated at type resolution time.)
- ``(#%scoped-var <depth-stx> <name-stx>)`` (no reason for depth to be represented as a syntax object, it's a limitation of the current architecture)

Note: All of these must be represented as `#<syntax>` objects, this is quite annoying.
      Might be better to preserve original syntax objects explicitly as another field in the representation.

Core forms for type expressions
-------------------------------

Type expressions have their own language parallel to that of value expressions.
It is possible to enter **type language** from **value language**, but not the other way around.
The distinction only applies from the name resolution phase onwards; previous phases are oblivious to it.

- ``(#%array-type <element-type> <size>)``
- ``(#%builtin-type I)`` aka ``int``
- ``(#%builtin-type V)`` aka ``Void``
- ``function-type`` which is actually a Racket struct right now, but should probably be brought in line
  (one disadvantage is that there is no natural place to store a srcloc)

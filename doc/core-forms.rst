Core forms
==========

(work in progress)

- ``(#%app <func> <args>...*)``
- ``(#%begin <stmt> ...+)``
- ``(#%construct <type> <args>...*)``
- ``(#%dot <expr> <name>)``
- ``(#%if <expr> <then> <else>)``
- ``(#%scoped-var <depth-stx> <name-stx>)`` (no reason for depth to be represented as ``syntax``, it's a limitation of the current architecture)

Note: All of these must be represented as `#<syntax>` objects, this is quite annoying.
      Might be better to preserve original syntax objects explicitly as another field in the representation.

Core forms for type expressions
-------------------------------

- ``(#%array-type <element-type> <size>)``
- ``(#%builtin-type I)`` aka ``int``
- ``(#%builtin-type V)`` aka ``Void``
- ``function-type`` which is actually a Racket struct right now, but should probably be brought in line
  (one disadvantage is that there is no natural place to store a srcloc)

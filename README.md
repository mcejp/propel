## Propel language

Run tests: `PLT_CS_DEBUG=1 raco test test*.rkt`

2048:

`PLT_CS_DEBUG=1 racket main.rkt && g++ -o 2048 out/2048/50-cpp.cpp harness.cpp && ./2048`

```
   Source (DSL in Racket)
-> Source with macros expanded (propel.rkt)
-> Source with syntax forms expanded (`player.pos.x`, `#%app` etc; propel-syntax.rkt)
-> Resolved names (propel-names.rkt)
-> Resolved types (propel-types.rkt)
```

### Primitive types

- `void` / `nil`
- `int`

### Core forms (TBD)

- `(#%app <func> <args>)`
- `(#%begin <stmt> ...+)`
- `(#%construct <type> <args>)`
- `(#%dot <expr> <name>)`
- `(#%if <expr> <then> <else>)`
- `(#%scoped-var <depth-stx> <name-stx>)` (no reason for depth to be represented with a `#(syntax)`, it's a limitation of the current architecture)

Note: All of these must be represented as `#<syntax>` objects, this is quite annoying.
      Might be better to preserve original syntax objects explicitly as another field in the representation.

#### Already deprecated

- `(#%argument <name-stx>)`
- `(#%builtin-function <name-stx>)` -- there doesn't seem to be any need to have this instead of just `(#%scoped-var 0 <name-stx>)`
- `(#%module-function <name>)`

### Open questions

- how to represent types in compiler?
- why aren't we using `syntax-parse`? -> because we need to execute code, not merely fill a template
- usage of pairs vs lists for AST structures -> lists get printed more consistently, pairs can get mis-interpreted as list heads.
  Should experiment with structs as well.

### Scoping

- for now, it is not very elegant:
  - types can be built-in or module-level
  - functions can be built-in or module-level (functions names are _not_ values)
  - (constants can be built-in or module-level or local)
  - variables can be built-in or module-level or arguments or local

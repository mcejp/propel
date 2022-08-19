## Propel language

```
   Source (DSL in Racket)
-> Source with macros expanded (propel.rkt)
-> Source with syntax forms expanded (`player.pos.x`, `#%app` etc; propel-syntax.rkt)
-> Resolved names (propel-names.rkt)
-> Resolved types
```

### Primitive types

- `void` / `nil`
- `int`

### Core forms (TBD)

- `(#%app <func> <args>)`
- `(#%begin <stmt> ...+)`
- `(#%dot <expr> <name>)`
- `(#%if <expr> <then> <else>)`
- `(#%var <scope-num> <name>)`

Note: All of these must be represented as `#<syntax>` objects, this is quite annoying.
      Might be better to preserve original syntax objects explicitly as another field in the representation.

#### Already deprecated

- `(#%argument <name-stx>)`
- `(#%builtin-function <name-stx>)`
- `(#%module-function <name>)`

### Open questions

- how to represent types in compiler?

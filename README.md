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

#### Already deprecated

- `(#%argument <name>)`
- `(#%builtin-function <name>)`
- `(#%module-function <name>)`

## Propel language

Run tests: `PLT_CS_DEBUG=1 raco test test*.rkt`

2048:

`PLT_CS_DEBUG=1 racket main.rkt && g++ -o 2048 out/2048/50-cpp.cpp harness.cpp && ./2048`

### Primitive types

- `void` / `nil`
- `int`

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

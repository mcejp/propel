## Propel language

Run tests: `PLT_CS_DEBUG=1 raco test test*.rkt`

2048:

`PLT_CS_DEBUG=1 racket main.rkt && g++ -o 2048 out/2048/50-cpp.cpp harness.cpp && ./2048`

Cloc:

`cloc *.rkt forms/*.rkt tests/*.rkt`

### Primitive types

- `void` / `nil`
- `int`

### Open questions

- how to represent types in compiler? -> right now it is a mixture of Racket structures and generic _type forms_
- why aren't we using `syntax-parse`? -> because we need to execute code, not merely fill a template
- usage of pairs vs lists for AST structures -> lists get printed more consistently, pairs can get mis-interpreted as list heads.
  Should experiment with structs as well.

C++ backend
===========

Rationale (vs LLVM IR, direct machine code, bytecode etc):

- C is close enough in execution model (static allocations etc.)
  - can leave many hard problems to be solved by C compiler
- portable! (not the case for LLVM IR)
- performance and memory efficiency of native code


C vs C++:

- C++ easier to emit, as well as more readable (e.g., can declare variables anywhere)
  - C99 not supported by Open Watcom!
- C++ compiler availability pretty good, but might still exclude some obscure platforms/compilers
- need a possibility to manage C vs C++ function linkage -- both for imported and exported functions

==> Plain C output option would be nice, but is not high priority

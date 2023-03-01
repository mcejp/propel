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

Original backend
----------------

The main thing to watch out for is that not every Propel expression translates to a C++ expression.
Consider the following example::

  (def foo (+ (bar)
    (if baz
        1
        (begin
          (print "Warning: not baz!")
          2))))

This must transpile to something like:

.. code-block:: c++

  int tmp1 = bar();
  int tmp2;
  if (baz) {
      tmp2 = 1;
  }
  else {
      print("Warning: not baz!");
      tmp2 = 2;
  }
  int foo = tmp1 + tmp2;

The current backend is broken -- it can re-order expressions incorrectly.

``format-form`` works by returning a pair of values:
 - a list of strings representing lines of code to be emitted
 - a string representing the ultimate expression



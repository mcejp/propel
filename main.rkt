#lang racket

(require "backend-c++.rkt"
         "c++-passes.rkt"
         "forms/_all.rkt"
         "propel-expand.rkt"
         "propel-names.rkt"
         "propel-serialize.rkt"
         "propel-syntax.rkt"
         "propel-types.rkt")

(define (compile-propel-module path [intermediate-output-dir #f])
  (when intermediate-output-dir
    (make-directory* intermediate-output-dir))

  #;(call-with-output-file
     "parsed.rkt"
     (λ (out) (write (serialize (module-functions propel-module)) out))
     #:exists 'truncate/replace)
  ; the syntax tree *can* be serialized, but the result is not nice.
  ; better to serialize just datums and preserve source locations using a custom representation
  #;(call-with-output-file
     "parsed.rkt"
     (λ (out) (pretty-write (serialize (module-functions propel-module)) out))
     #:exists 'truncate/replace)

  (define (dump filename mod-stx [mod-tt #f])
    (when intermediate-output-dir
      (call-with-output-file
       (build-path intermediate-output-dir filename)
       (λ (out) (pretty-write (serialize-module mod-stx mod-tt) out))
       #:exists 'truncate/replace)))

  (define (with-output-to-nowhere thunk)
    (parameterize ([current-output-port (open-output-nowhere)]) (thunk)))

  (define (with-intermediate-output-to-file filename thunk)
    (if intermediate-output-dir
        (with-output-to-file (build-path intermediate-output-dir filename)
                             thunk
                             #:exists 'replace)
        (with-output-to-nowhere thunk)))

  (define form-db (make-hash))
  (register-builtin-forms form-db)

  ;; load module source
  (define stx (parse-module path))

  ;; initialize expander
  (define expander-state (make-expander-state))

  ;; load built-in definitions
  (define builtins-stx (parse-module "propel-builtins.rkt"))
  (expand-forms expander-state builtins-stx)

  ;; expand macros
  (define mod-expanded
    ;; patch up directory for imports from transformers
    (parameterize ([current-load-relative-directory
                    (path->complete-path "tests")])
      (expand-forms expander-state stx)))
  (dump "10-expanded.rkt" mod-expanded)

  ;; resolve non-core forms
  (define mod-core-forms (resolve-forms form-db mod-expanded))
  (dump "20-core-forms.rkt" mod-core-forms)

  ;; resolve names
  (define mod-names (resolve-names form-db mod-core-forms))
  (dump "30-names.rkt" mod-names)

  ;; resolve types
  (define mod-typed (resolve-types form-db mod-names))
  (dump "40-types.rkt" mod-typed)

  (define additional-passes
    (list (cons c++-lift-operators "45-binary-operators.rkt")))

  (for ([pass additional-passes])
    (match-define (cons f dump-filename) pass)

    ;; this is just much more readable than for/fold
    (set! mod-typed (f mod-typed))
    (dump dump-filename mod-typed))

  (with-intermediate-output-to-file "50-cpp.cpp"
                                    (λ () (compile-module-to-c++ mod-typed))))

(for ([testcase '("2048" "2048-board"
                         "def-array"
                         "def-local"
                         "deftype"
                         "factorial"
                         "hello"
                         "vga-palette"
                         "void")])
  (compile-propel-module (~a "tests/" testcase ".rkt") (~a "out/" testcase)))

#lang racket

(require racket/cmdline
         racket/runtime-path
         "backend-c++.rkt"
         "c++-passes.rkt"
         "forms/_all.rkt"
         "propel-expand.rkt"
         "propel-names.rkt"
         "propel-syntax.rkt"
         "propel-types.rkt")

(define c-linkage (make-parameter #f))
(define output (make-parameter null))

(define file-to-compile
  ;; More examples at https://docs.racket-lang.org/reference/Command-Line_Parsing.html#%28form._%28%28lib._racket%2Fcmdline..rkt%29._command-line%29%29
  (command-line
   #:program "propel-compile"
   #:once-each ["-o" filename "Output file name" (output filename)]   ;; FIXME: this defaults to '() which causes an error
   #:once-each ["--extern-c" "Use C function linkage" (c-linkage #t)]
   #:args (filename)
   filename))

(define-runtime-path builtins "propel-builtins.rkt")

;; Should the compilation pipeline be librarized?
;; Clang does this, but maybe not worth the effort right now.
(define (compile-propel-module path output-path)
  (define form-db (make-hash))
  (register-builtin-forms form-db)

  ;; load module source
  (define stx (parse-module path))

  ;; initialize expander
  (define expander-state (make-expander-state))

  ;; load built-in definitions
  (define builtins-stx (parse-module builtins))
  (expand-forms expander-state builtins-stx)

  ;; expand macros
  (define mod-expanded (expand-forms expander-state stx))

  ;; resolve non-core forms
  (define mod-core-forms (resolve-forms form-db mod-expanded))

  ;; resolve names
  (define mod-names (resolve-names form-db mod-core-forms))

  ;; resolve types
  (define mod-typed (resolve-types form-db mod-names))

  (define additional-passes
    (list (cons c++-lift-operators-and-array-init "45-binary-operators.rkt")))

  (for ([pass additional-passes])
    (match-define (cons f _) pass)

    ;; this is just much more readable than for/fold
    (set! mod-typed (f mod-typed)))

  (with-output-to-file output-path
                       (λ () (compile-module-to-c++ mod-typed))
                       #:exists 'replace))

(parameterize ([use-c-linkage (c-linkage)])
  (compile-propel-module file-to-compile (output)))

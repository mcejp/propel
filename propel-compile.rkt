#lang racket

(require racket/cmdline
         racket/runtime-path
         "backend-c++.rkt"
         "forms/_all.rkt"
         "propel-expand.rkt"
         "propel-names.rkt"
         "propel-syntax.rkt"
         "propel-types.rkt")

; (define verbose-mode (make-parameter #f))
; (define profiling-on (make-parameter #f))
(define output (make-parameter null))
; (define link-flags (make-parameter null))

(define file-to-compile
  ;; More examples at https://docs.racket-lang.org/reference/Command-Line_Parsing.html#%28form._%28%28lib._racket%2Fcmdline..rkt%29._command-line%29%29
  (command-line
   #:program "propel-compile"
   #:once-each ["-o" filename "Output file name" (output filename)]
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
  (define tt (resolve-types form-db mod-names))

  (with-output-to-file output-path
                       (λ () (compile-module-to-c++ mod-names tt))
                       #:exists 'replace))

(compile-propel-module file-to-compile (output))

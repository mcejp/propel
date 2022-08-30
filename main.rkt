#lang racket

(require racket/serialize
         racket/struct
         "backend-c++.rkt"
         "module.rkt"
         "propel-models.rkt"
         "propel-names.rkt"
         "propel-serialize.rkt"
         "propel-syntax.rkt"
         "propel-types.rkt")

(require racket/fasl)

(define (compile-propel-module path [intermediate-output-dir #f])
  (when intermediate-output-dir
    (make-directory* intermediate-output-dir))

  ; TODO: iterate over all test cases, or better, encapsulate compile flow
  (define propel-module (parse-module path))

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

  (define (dump filename mod)
    (when intermediate-output-dir
      (call-with-output-file (build-path intermediate-output-dir filename)
                             (λ (out) (pretty-write (serialize-module mod) out))
                             #:exists 'truncate/replace)))

  (define (with-output-to-nowhere thunk)
    (parameterize ([current-output-port (open-output-nowhere)]) (thunk)))

  (define (with-intermediate-output-to-file filename thunk)
    (if intermediate-output-dir
        (with-output-to-file (build-path intermediate-output-dir filename)
                             thunk
                             #:exists 'replace)
        (with-output-to-nowhere thunk)))

  (dump "10-parsed.rkt" propel-module)

  ;(print module-functions)

  (resolve-forms/module! propel-module)
  (dump "20-core-forms.rkt" propel-module)

  (resolve-names/module! propel-module)
  (dump "30-names.rkt" propel-module)

  (update-module-functions propel-module resolve-types/function)
  (dump "40-types.rkt" propel-module)

  (with-intermediate-output-to-file
   "50-cpp.cpp"
   (λ () (compile-module-to-c++ propel-module))))

(compile-propel-module "tests/factorial.rkt" "out")

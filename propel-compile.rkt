#lang racket

(require racket/serialize
         racket/struct
         "backend-c++.rkt"
         "propel-models.rkt"
         "propel-names.rkt"
         "propel-serialize.rkt"
         "propel-syntax.rkt"
         "propel-types.rkt"
         )

(require racket/fasl)

; TODO: iterate over all test cases, or better, encapsulate compile flow
(define propel-module (parse-module "tests/factorial.rkt"))

#;(call-with-output-file "parsed.rkt"
    (λ (out) (write (serialize (module-functions propel-module)) out))
    #:exists 'truncate/replace)
; the syntax tree *can* be serialized, but the result is not nice.
; better to serialize just datums and preserve source locations using a custom representation
#;(call-with-output-file "parsed.rkt"
    (λ (out) (pretty-write (serialize (module-functions propel-module)) out))
    #:exists 'truncate/replace)

(define (dump filename mod)
  (call-with-output-file filename
    (λ (out) (pretty-write (serialize-module mod) out))
    #:exists 'truncate/replace)
)

(dump "out/10-parsed.rkt" propel-module)

;(print module-functions)

(resolve-forms/module! propel-module)
(dump "out/20-core-forms.rkt" propel-module)

(define (update-functions updater)
  (define fs (module-functions propel-module))
  (hash-for-each fs (λ (name f) (let ([f* (updater f)])
                                  (begin
                                    ;(println f*)
                                    (hash-set! fs name f*))
                                    ))))


(update-functions resolve-names/function)
(dump "out/30-names.rkt" propel-module)

(update-functions resolve-types/function)
(dump "out/40-types.rkt" propel-module)

(with-output-to-file "out/50-cpp.cpp"
                     (λ () (compile-module-to-c++ propel-module))
                     #:exists 'replace)

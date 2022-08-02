#lang racket

(require racket/serialize
         "flyover.rkt"
         "propel-names.rkt"
         "propel-syntax.rkt"
         )

(require racket/fasl)

#;(call-with-output-file "parsed.rkt"
  (λ (out) (write (serialize (module-functions propel-module)) out))
  #:exists 'truncate/replace)
; the syntax tree *can* be serialized, but the result is not nice.
; better to serialize just datums and preserve source locations using a custom representation
#;(call-with-output-file "parsed.fasl"
    (λ (out) (s-exp->fasl (serialize module-functions) out))
    #:exists 'truncate/replace)

;(print module-functions)

(hash-for-each (module-functions propel-module)
               (λ (name f) (print (resolve-names/function f)))
               )

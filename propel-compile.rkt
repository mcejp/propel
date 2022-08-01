#lang racket

(require racket/serialize
         "flyover.rkt"
         "propel-names.rkt")

(require racket/fasl)

; the syntax tree *can* be serialized, but the result is not nice
#;(call-with-output-file "parsed.fasl"
  (λ (out) (s-exp->fasl (serialize module-functions) out))
  #:exists 'truncate/replace)

;(print module-functions)

(hash-for-each module-functions (lambda (name f) (print (resolve-names/function f))))

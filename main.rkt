#lang racket

(require racket/serialize
         racket/struct
         "backend-c++.rkt"
         "module.rkt"
         "propel-models.rkt"
         "propel-names.rkt"
         "propel-serialize.rkt"
         "propel-syntax.rkt"
         "propel-types.rkt"
         "scope.rkt")

(require racket/fasl)

(define (compile-propel-module path [intermediate-output-dir #f])
  (when intermediate-output-dir
    (make-directory* intermediate-output-dir))

  (define propel-module-stx (parse-module path))

  ; convert module syntax into legacy module structure

  (define (module-legacy-parse stx)
    (define propel-module
      (module (make-hash)
              (scope base-scope 1 (make-hash) (make-hash) (make-hash) #t #t)
        (resolve-forms (datum->syntax stx (cons #'begin (syntax-e stx)) stx))))

    (define (defun1 stx name-stx args-stx ret-stx body-stx)
      (define func-scope
        (scope (module-scope propel-module)
               2
               (make-hash)
               (make-hash)
               (make-hash)
               #f
               #f))
      (define name (syntax->datum name-stx))
      (define args (syntax->datum args-stx)) ; bad
      (define ret (syntax->datum ret-stx)) ; baaad
      (define func
        (function name args ret body-stx #f propel-module func-scope))
      (hash-set! (module-functions propel-module) name func)
      (hash-set! (scope-objects (module-scope propel-module))
                 name
                 (cons '#%module-function name)))

    (for ([stx (syntax-e propel-module-stx)])
      (match (syntax-e stx)
        [(list (? is-decl-external-fun? t) name-stx args-stx ret-stx) (void)]
        [(list (? is-defun? t) name args ret body ...)
         (defun1
          stx
          name
          args
          ret
          (datum->syntax stx (cons (datum->syntax t 'begin t) body) stx))]
        [(list (? is-deftype? t) name definition)
         ;;(hash-set! (module-types propel-module) name type)
         ;; this is probably wrong... should just put like a marker and then emit a #deftype in the program stream
         (hash-set! (scope-types (module-scope propel-module))
                    (syntax->datum name) ; not great
                    (list '#%deftype (syntax->datum definition) ; bad!
                          ))]))
    propel-module)

  (define propel-module (module-legacy-parse propel-module-stx))

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

  (resolve-types #f (module-scope propel-module) (module-body propel-module))

  (update-module-functions propel-module resolve-types/function)
  (dump "40-types.rkt" propel-module)

  (with-intermediate-output-to-file
   "50-cpp.cpp"
   (λ () (compile-module-to-c++ propel-module))))

(for ([testcase '("def-local" "deftype" "factorial" "hello")])
  (compile-propel-module (~a "tests/" testcase ".rkt") (~a "out/" testcase)))

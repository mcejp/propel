#lang racket

;;; NB: The code that follows is a total disaster.

(require (for-syntax racket/function
                     racket/match
                     )

         "module.rkt"
         "propel-models.rkt"
         "scope.rkt"
         )

(provide (except-out (all-from-out racket) #%module-begin)
         (rename-out [module-begin #%module-begin])
         deftype
         defun
         )

(define-syntax deftype
  (lambda (stx)
    (match (syntax-e stx)
      [(list _deftype name definition)
       (datum->syntax stx (list #'module-deftype `(quote ,(syntax-e name)) `(quote ,definition)))
      ])))

(define-syntax defun
  (lambda (stx)
    (match (syntax-e stx)
      ; split the different parts of the syntax
      [(list _defun name args ret body ...)
       (defun1 stx name args ret (datum->syntax stx
                                                (cons (datum->syntax _defun 'begin _defun) body)
                                                stx))]
      )))

; TODO comments explaining what the body looks like during each step
(define-for-syntax (defun1 stx name args ret body)
  ;(display body)
  ; expand macros
  (define mapped-form (exprec body))
  ;(display mapped-form)

  ;(define quoted-form #`(quote #,mapped-form))
  ; force lexical context of original expression
  ;(define new-stx (datum->syntax stx (syntax->datum quoted-form) stx))
  ;(display new-stx)

  ; add to preprocessed function to module function table
  (define f #`(function '#,name '#,args '#,ret (quote-syntax #,mapped-form) #f #f #f))
  ;#`(module-defun '#,(syntax-e name) (function '#,name '#,args '#,ret #,new-stx))
  (define final-stx (datum->syntax stx (list #'module-defun `(quote ,(syntax-e name)) f)))
  ;(println final-stx)
  final-stx
  )

; loal-expand-recusrive
; expand recursively without complaining about unbound identifiers
(define-for-syntax (exprec stx)
  ;(display (syntax-e stx))
  (define rec (curry exprec))
  (define (exp stx) (local-expand stx 'expression #f))

  (match (syntax-e stx)
    [(list a ...) (exp (datum->syntax stx (map rec a) stx))]
    [a stx]
    )
  )

; oh no no no no
(define propel-module (module (make-hash) (scope base-scope (make-hash) (make-hash) (make-hash) #t #t)))

(define (module-deftype name type)
  ;;(hash-set! (module-types propel-module) name type)
  ;; this is probably wrong... should just put like a marker and then emit a #deftype in the program stream
  (hash-set! (scope-types (module-scope propel-module)) name (list '#%deftype type)))

(define (module-defun name func)
  (define func-scope (scope (module-scope propel-module) (make-hash) (make-hash) (make-hash) #f #f))
  (define func* (struct-copy function func [module propel-module] [scope func-scope]))
  (hash-set! (module-functions propel-module) name func*)
  (hash-set! (scope-objects (module-scope propel-module)) name (cons '#%module-function name)))

(define-syntax-rule (module-begin expr ...)
  (#%module-begin
   ;(display "module begin")
   ; oh no no no NO
   (hash-clear! (module-functions propel-module))
   (hash-clear! (scope-objects (module-scope propel-module)))
   (hash-clear! (scope-types (module-scope propel-module)))

   expr ...
   ;(process-module-functions module-functions)
   (provide propel-module))
  )

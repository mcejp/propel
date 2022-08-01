#lang racket

(require (for-syntax racket/function
                     racket/match
                     racket/string
                     ;syntax/parse
                     )
         ;syntax/parse/define

         "propel-syntax.rkt"
         )

(provide (except-out (all-from-out racket) #%module-begin)
         (rename-out [module-begin #%module-begin])
         defun
         )

(define-syntax defun
  (lambda (stx)
    (match (syntax-e stx)
      ; split the different parts of the syntax
      [(list _defun name args ret body ...)
       (defun1 stx name args ret (datum->syntax stx (cons 'begin body)))])))

; TODO comments explaining what the body looks like during each step
(define-for-syntax (defun1 stx name args ret body)
  ;(display body)
  ; first expand macros, then "map syntax"
  ; done this way so that macro can still use our syntax like 'player.pos'
  (define mapped-form (map-syntax-all (exprec body)))
  ;(display mapped-form)

  ;(define quoted-form #`(quote #,mapped-form))
  ; force lexical context of original expression
  ;(define new-stx (datum->syntax stx (syntax->datum quoted-form) stx))
  ;(display new-stx)

  ; add to preprocessed function to module function table
  (define f #`(function '#,name '#,args '#,ret (quote-syntax #,mapped-form)))
  ;#`(module-defun '#,(syntax-e name) (function '#,name '#,args '#,ret #,new-stx))
  (define final-stx (datum->syntax stx (list #'module-defun `(quote ,(syntax-e name)) f)))
  (print final-stx)
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

(define-for-syntax (map-syntax-all stx)
  (map-syntax-recursive map-syntax-atom stx)
  )

; map an AST sub-tree
(define-for-syntax (map-syntax-recursive atom-proc stx)
  ;(display (syntax-e stx))
  (define rec (curry map-syntax-recursive atom-proc))
  (match (syntax-e stx)
    [(list a ...) (datum->syntax stx (map rec a) stx)]
    [a (atom-proc stx)]
    )
  )

; map a syntax element that is _not_ a list
; for example, replace `camera.set-pos` with `(. camera set-pos)`
; input: syntax, output: syntax
(define-for-syntax (map-syntax-atom stx)
  (define stxe (syntax-e stx))
  (match stxe
    ; match symbols including stuff like "x.y.z..."
    [(? symbol? sym)
     (map-dot-expression stx (string-split (symbol->string sym) "."))
     ]
    [a a]
    )
  )

; convert player.pos.x -> (. (. player pos) x)
; tokens must be a non-empty list of strings
; we return a syntax
(define-for-syntax (map-dot-expression stx tokens)
  (define rec (curry map-dot-expression stx))
  ;(display tokens)
  (datum->syntax stx
                 (match tokens
                   [(list a) (string->symbol a)]
                   [(list a ...) `(op-. ,(rec (list (car a))) ,(rec (cdr a )))]
                   )
                 stx)
  )

; oh no no no no
(define module-functions (make-hash))

(define (module-defun name func)
  (hash-set! module-functions name func))

(define-syntax-rule (module-begin expr ...)
  (#%module-begin
   ;(display "module begin")
   expr ...
   ;(process-module-functions module-functions)
   (provide module-functions))
  )

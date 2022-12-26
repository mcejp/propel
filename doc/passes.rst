Compilation passes
==================

#. Source
#. Source with macros expanded (propel-expand.rkt)
#. Source with syntax forms expanded (``player.pos.x``, ``#%app``, etc; propel-syntax.rkt)
#. Resolved names (propel-names.rkt)
#. Resolved types (propel-types.rkt)

How to implement a new pass
---------------------------

You can start from this basic template::

  (define (my-pass stx)
    (define rec my-pass) ; recurse
    ;; (printf "my-pass ~a\n" (syntax-e stx))

    (datum->syntax stx
      (match (syntax-e stx)
        ;; TODO: custom rules here

        ;; handle forms recursively
        [(? list? exprs) (map rec exprs)]
        ;; pass everything else unchanged
        [_ stx])
      stx))

Ideally the recursion logic could be factored out into a function.

Internal APIs
=============

propel-expand::

  (make-expander-state)
  (expand-forms state stx)

propel-names::

  (resolve-names form-db stx)

propel-types::

  (resolve-types form-db current-scope stx)

backend-c++::

  (compile-module-to-c++ mod-stx mod-tt)

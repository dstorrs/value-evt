#lang info
(define collection "value-evt")
(define deps '("base"))
(define build-deps '("scribble-lib" "sandbox-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/value-evt.scrbl" ())))
(define pkg-desc "Allows syncing on arbitrary values.  Events are unchanged, procedures sync to their return value unless told not to, lists sync recursively, all other values sync to themselves.")
(define version "0.1")
(define pkg-authors '("David K. Storrs"))

#lang info
(define collection "value-evt")
(define deps '("base"))
(define build-deps '("scribble-lib" "sandbox-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/value-evt.scrbl")))
(define pkg-desc "Wraps an arbitrary value into a synchronizable event.  The synchronization result of the event is the original value, with two exceptions:  Procedures sync to their return value and lists sync recursively.  Both of these values can be disabled via keywords.")
(define version "0.1")
(define pkg-authors '("David K. Storrs"))

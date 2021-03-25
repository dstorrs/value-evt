#lang info
(define collection "value-evt")
(define deps '("base"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/value-evt.scrbl" ())))
(define pkg-desc "Wraps an arbitrary value into a synchronizable event.  The synchronization result of the event is the original value.")
(define version "0.1")
(define pkg-authors '("David K. Storrs"))

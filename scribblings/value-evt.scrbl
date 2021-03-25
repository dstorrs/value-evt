#lang scribble/manual

@(require (for-label racket value-evt)
          racket/sandbox
          scribble/example)


@title{value-evt}
@author{David K. Storrs}

@defmodule[value-evt]

@(define eval
   (call-with-trusted-sandbox-configuration
    (lambda ()
      (parameterize ([sandbox-output 'string]
                     [sandbox-error-output 'string]
                     [sandbox-memory-limit 50])
        [make-evaluator #:requires (list "../main.rkt") 'racket]))))


Wraps an arbitrary value into a synchronizable event.  The synchronization result of the event is the original value. 

@section{Synopsis}

@examples[
          #:eval eval
          #:label #f

(define e (value-evt 9))
(evt? e)
(sync e)
(value-evt-value e)
]

@section{API}

@defproc[(value-evt [v any/c]) value-evt?]{Create a value-evt that will produce the specified value when synchronized.}

@defproc[(value-evt-value [e value-evt?]) any/c]{Return the value of the event without using the synchronization mechanisms.}


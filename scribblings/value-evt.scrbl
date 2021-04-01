#lang scribble/manual

@(require (for-label racket/base value-evt)
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
        [make-evaluator #:requires (list 'value-evt) 'racket]))))


Wraps an arbitrary value into a synchronizable event.  

@itemize[
@item{Syncing something that is already an event works as usual.}
@item{Syncing on a procedure returns the procedure's result unless you disable this behavior via the @racket[#:eval-proc?] keyword. (If evaluated, the procedure is called with no arguments.) }
@item{Syncing on a list recursively syncs the elements of the list unless you disable this behavior via the @racket[#:recurse-lists?] keyword.}
@item{In all other cases, the synchronization result is the original value.}
]

@section{Synopsis}

@examples[
          #:eval eval
          #:label #f

@#reader scribble/comment-reader
; value-evts are both evt? and value-evt?. They sync to their argument
(define e (value-evt 9))
e
(evt? e)
(value-evt? e)
(sync e)

@#reader scribble/comment-reader
;
@#reader scribble/comment-reader
; By default, syncing on a procedure syncs to the return value
(define proc (lambda () (+ 2 2)))
(sync (value-evt proc))
@#reader scribble/comment-reader
; You can instead get the procedure itself back
(sync (value-evt proc #:eval-proc? #f))
@#reader scribble/comment-reader
; It's not a problem to specify #:eval-proc? on something that isn't a procedure
(sync (value-evt "eval-proc? keyword is ignored for non-proc" #:eval-proc? #f))

@#reader scribble/comment-reader
;
@#reader scribble/comment-reader
; eventify always returns an evt
@#reader scribble/comment-reader
; Things that are evts are unchanged
(define ch (make-channel))
(evt? ch)
(eq? ch (eventify ch))
@#reader scribble/comment-reader
; Things that are not evts become value-evts
(evt? 'bob)
(evt? (eventify 'bob))

@#reader scribble/comment-reader
;
@#reader scribble/comment-reader
; by default, value-evts containing a list sync recursively
(let ([result-ch (make-channel)]
      [arg-ch1   (make-channel)]
      [arg-ch2   (make-channel)])
  (void (thread (λ () (channel-put result-ch (sync (value-evt (list arg-ch1 arg-ch2)))))))
  (channel-put arg-ch1 'arg1-ch-ok)
  (channel-put arg-ch2 'arg2-ch-ok)
  (sync result-ch))


@#reader scribble/comment-reader
;
@#reader scribble/comment-reader
; You can ask for it to return the original list
(let ([arg-ch1   (make-channel)]
      [arg-ch2   (make-channel)])
(sync (value-evt (list arg-ch1 arg-ch2) #:recurse-lists? #f)))

@#reader scribble/comment-reader
;
@#reader scribble/comment-reader
; all-evt is the same as value-evt but takes a rest argument
@#reader scribble/comment-reader
; so you don't have to supply your own list
(let ([result-ch (make-channel)]
      [arg-ch1   (make-channel)]
      [arg-ch2   (make-channel)])
  (define e (all-evt  arg-ch1 arg-ch2))
  (printf "all-evt returns: ~v" e)
  (void (thread (λ () (channel-put result-ch (sync e)))))
  (channel-put arg-ch1 'arg1-ch-ok)
  (channel-put arg-ch2 'arg2-ch-ok)
  (sync result-ch))
]

@section{API}

@defproc[(value-evt [v any/c][#:eval-proc? eval-proc? boolean? #t][#:recurse-lists? recurse-lists? boolean? #t]) value-evt?]{Creates a synchronizable value-evt that by default will produce the original value when synced.  There are two exceptions:

@itemlist[
@item{If the value is a procedure and @racketid[eval-proc?] is @racket[#t] (the default) then the procedure will be called with no arguments and the synchronization result of the value-evt will be the return value of the procedure.}
@item{If the value is a list and @racketid[recurse-lists?] is @racket[#t] (the default) then each element of the list will have @racket[(compose1 sync eventify)] called on it and the synchronization event of the original event will be a list containing the synchronization results of each of the list items.  This process is recursive.}  
]

This provides a convenient way to run an arbitrary function and wait for it to complete without having to do polling, apply strictures to your interface (if the function is being passed in), or otherwise contort the code.  If you want to actually return the lambda then you may use @racket[#:eval-proc? #f].  Similarly, @racket[#:recurse-lists?] makes it easy to handle the case where you want to wait for multiple events to complete before proceeding.  A typical example would be waiting for a network connection to a server and simultaneously waiting for configuration files to be read and setup to be performed. 
}

@defproc[(value-evt? [v any/c]) boolean?]{Is the value a value-evt?}

@defproc[(eventify [v any/c] [#:eval-proc? eval-proc? boolean? #t][#:recurse-lists? recurse-lists? boolean? #t]) evt?]{If @racketid[v] is a synchronizable event, return it unchanged.  Otherwise, return @racket[(value-evt v #:eval-proc? eval-proc? #:recurse-lists? recurse-lists?)].  In most cases you'll want to use this instead of using @racket[value-evt] directly, since syncing on a @racket[(value-evt my-channel)] will get you the channel itself instead of the first message on it.}

@defproc[(all-evt  [#:eval-proc? eval-proc? boolean? #t] [#:recurse-lists? recurse-lists? boolean? #t] [arg any/c] ...) value-evt?]{Returns a value-evt the value of which is @racket[(map eventify args)].}




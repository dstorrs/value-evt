value-evt
===========

Wraps an arbitrary value into a synchronizable event.  The synchronization result of the event is the original value. 

See the docs for the most up-to-date info because this README might fall behind.  As of initial creation:

```
; value-evts are both evt? and value-evt?. They sync to their argument
> (define e (value-evt 9))
> e

#<value-evt>
> (evt? e)

#t
> (value-evt? e)

#t
> (sync e)

9
; 
; By default, syncing on a procedure syncs to the return value
> (define proc (lambda () (+ 2 2)))
> (sync (value-evt proc))

4
; You can instead get the procedure itself back
> (sync (value-evt proc #:eval-proc? #f))

#<procedure:proc>
; It's not a problem to specify #:eval-proc? on something that isn't a procedure
> (sync (value-evt "eval-proc? keyword is ignored for non-proc" #:eval-proc? #f))

"eval-proc? keyword is ignored for non-proc"
; 
; eventify always returns an evt
; Things that are evts are unchanged
> (define ch (make-channel))
> (evt? ch)

#t
> (eq? ch (eventify ch))

#t
; Things that are not evts become value-evts
> (evt? 'bob)

#f
> (evt? (eventify 'bob))

#t
; 
; by default, value-evts containing a list sync recursively
> (let ([result-ch (make-channel)]
        [arg-ch1   (make-channel)]
        [arg-ch2   (make-channel)])
    (void (thread (λ () (channel-put result-ch (sync (value-evt (list arg-ch1 arg-ch2)))))))
    (channel-put arg-ch1 'arg1-ch-ok)
    (channel-put arg-ch2 'arg2-ch-ok)
    (sync result-ch))

'(arg1-ch-ok arg2-ch-ok)
; 
; You can ask for it to return the original list
> (let ([arg-ch1   (make-channel)]
        [arg-ch2   (make-channel)])
  (sync (value-evt (list arg-ch1 arg-ch2) #:recurse-lists? #f)))

'(#<channel> #<channel>)
; 
; all-evt is the same as value-evt but takes a rest argument
; so you don't have to supply your own list
> (let ([result-ch (make-channel)]
        [arg-ch1   (make-channel)]
        [arg-ch2   (make-channel)])
    (define e (all-evt  arg-ch1 arg-ch2))
    (printf "all-evt returns: ~v" e)
    (void (thread (λ () (channel-put result-ch (sync e)))))
    (channel-put arg-ch1 'arg1-ch-ok)
    (channel-put arg-ch2 'arg2-ch-ok)
    (sync result-ch))

all-evt returns: #<value-evt>

'(arg1-ch-ok arg2-ch-ok)
```
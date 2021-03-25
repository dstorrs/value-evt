value-evt
===========

Wraps an arbitrary value into a synchronizable event.  The synchronization result of the event is the original value. 

```
> (define e (value-evt 9))
> (evt? e)
#t
> (sync e)
9
> (value-evt-value e)
9
```
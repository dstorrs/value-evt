#lang racket/base

(require racket/async-channel)

(provide value-evt (rename-out (value-storer-value value-evt-value)))

(struct value-storer (value ch)
  #:reflection-name 'value-evt
  #:property prop:evt (λ (self)
                        (define ch (value-storer-ch self))
                        (async-channel-put ch (value-storer-value self))
                        ch))

(define (value-evt v)
  (value-storer v (make-async-channel)))



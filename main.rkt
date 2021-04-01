#lang racket/base

(require racket/async-channel
         racket/match)

(provide value-evt
         eventify
         all-evt
         (rename-out (value-storer? value-evt?)))

(define (value-storer-sync self)
  (match-define (value-storer val ch eval-proc? recurse-lists?) self)

  (define result
    (match val
      [(? procedure? v) #:when eval-proc?       (val)]
      [(? list?)        #:when recurse-lists?   (map (compose1 sync eventify) val)]
      [_                val]))
  (async-channel-put ch result)
  ch)


(struct value-storer (value ch eval-proc? recurse-lists?)
  #:reflection-name 'value-evt
  #:property prop:evt value-storer-sync)

(define (value-evt v #:eval-proc? [eval-proc? #t] #:recurse-lists? [recurse-lists? #t])
  (value-storer v (make-async-channel) eval-proc? recurse-lists?))

(define (eventify v  #:eval-proc? [eval-proc? #t] #:recurse-lists? [recurse-lists? #t])
  (if (evt? v) v (value-evt v #:eval-proc? eval-proc?)))

(define (all-evt  #:eval-proc? [eval-proc? #t] #:recurse-lists? [recurse-lists? #t] . args)
  (value-evt (map eventify args) #:eval-proc? eval-proc?      #:recurse-lists? recurse-lists?))

(module+ test
  (require rackunit)
  ;; Any code in this `test` submodule runs when this file is run using DrRacket
  ;; or with `raco test`. The code here does not run when this file is
  ;; required by another module.

  (define proc (lambda () (+ 2 2)))

  (check-eq? (sync (value-evt 4)) 4)
  (check-eq? (sync (value-evt proc)) 4)
  (check-eq? (sync (value-evt proc #:eval-proc? #f)) proc)

  (define result-ch (make-channel))
  (define arg-ch    (make-channel))
  (define sema      (make-semaphore 1))

  (void (thread (λ () (channel-put result-ch (sync (all-evt arg-ch sema))))))
  (channel-put arg-ch 'arg-ch-ok)
  (semaphore-post sema)
  (check-equal? (sync result-ch)
                (list 'arg-ch-ok sema))
  (check-equal? (sync (all-evt 'bob 'fred '(alice)))
                '(bob fred (alice)))
  )

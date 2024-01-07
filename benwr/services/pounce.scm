(define-module (benwr services pounce)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services configuration)
  #:use-module (gnu packages messaging)
  #:use-module (guix gexp)
  #:export (pounce-service-type)
)

(define (pounce-shepherd-service config)
  (map (lambda (network) (shepherd-service
    (provision (list (symbol-append 'pounce- (string->symbol network))))
    (requirement '(networking tailscaled file-systems))
    (start #~(make-forkexec-constructor
               (list "sh" "-c" (string-append "sleep 10; " #$(file-append pounce "/bin/pounce") " /etc/pounce/" #$network ".conf"))
               #:log-file (string-append "/var/log/pounce-" #$network ".log")))
    (stop #~(make-kill-destructor))
  )) config))

(define pounce-service-type (service-type
  (name 'pounce)
  (extensions (list (service-extension shepherd-root-service-type pounce-shepherd-service)))
  (default-value '())
  (description "Launch pounce.")))

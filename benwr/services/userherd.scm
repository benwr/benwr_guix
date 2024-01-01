(define-module (benwr services userherd)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services configuration)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (gnu packages base)
  #:use-module (benwr packages userherd)
  #:export (userherd-service-type)
)

(define (userherd-shepherd-service config)
  (let ((environment #~(list (string-append "PATH=" (string-append #$coreutils "/bin") ":/run/setuid-programs/sudo"))))
    (map
      (lambda (user)
        (shepherd-service
          (provision (list (symbol-append 'userherd- (string->symbol user))))
          (requirement '(user-processes))
          (start #~(make-forkexec-constructor
                     (list #$(file-append userherd "/bin/userherd") #$user)
                     #:log-file "/var/log/userherd.log"
                     #:environment-variables environment))
          (stop #~(make-kill-destructor))
         ))
      config)))

(define userherd-service-type
  (service-type
    (name 'userherd)
    (extensions (list (service-extension shepherd-root-service-type userherd-shepherd-service)))
    (default-value '())
    (description "Launch userherd")))

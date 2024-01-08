(define-module (benwr services userherd)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services configuration)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (gnu packages base)
  #:use-module (gnu packages admin)
  #:use-module (benwr packages userherd)
  #:export (userherd-service-type)
)

(define (userherd-shepherd-service config)
  (let ((environment #~(list (string-append "PATH=" #$coreutils "/bin:/run/setuid-programs:" #$shepherd "/bin:" #$daemontools "/bin"))))
    (map
      (lambda (user)
        (shepherd-service
          (provision (list (symbol-append 'userherd- (string->symbol user))))
          (requirement '(user-processes pam elogind))
          (start #~(make-forkexec-constructor
                     (list #$(file-append userherd "/bin/userherd") #$user)
                     #:log-file (string-append "/var/log/userherd-" #$user ".log")
                     #:environment-variables #$environment))
          (stop #~(make-kill-destructor))
         ))
      config)))

(define userherd-service-type
  (service-type
    (name 'userherd)
    (extensions (list (service-extension shepherd-root-service-type userherd-shepherd-service)))
    (default-value '())
    (description "Launch userherd")))

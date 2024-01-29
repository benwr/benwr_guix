(define-module (benwr services zabbix)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services configuration)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages monitoring)
  #:use-module (gnu system shadow)
  #:use-module (guix gexp)
  #:export (zabbix-service-type)
)

(define (zabbix-activation config)
  "Return the activation gexp for CONFIG."
  (with-imported-modules '((guix build utils))
    #~(begin
        (use-modules (guix build utils)
                     (ice-9 rdelim))
        (let ((user (getpw "zabbix")))
          (for-each (lambda (file)
                      (let ((directory (dirname file)))
                        (mkdir-p directory)
                        (chown directory (passwd:uid user) (passwd:gid user))
                        (chmod directory #o755)))
                    (list "/var/log/zabbix/zabbix-agent.log" "/var/run/zabbix/zabbix.pid"))))))

(define (zabbix-account config)
  (list
    (user-group (name "zabbix") (system? #t))
    (user-account
      (name "zabbix")
      (system? #t)
      (group "zabbix")
      (comment "zabbix privsep user")
      (home-directory "/var/run/zabbix")
      (shell (file-append shadow "/sbin/nologin"))
      )))

(define (zabbix-shepherd-service config)
  (list (shepherd-service
    (provision '(zabbix-agent))
    (requirement '(networking tailscaled file-systems user-processes))
    (documentation "Run Zabbix agent daemon")
    (start #~(make-forkexec-constructor
               (list #$(file-append zabbix-agentd "/sbin/zabbix_agentd") "--foreground" "--config" "/etc/zabbix/zabbix-agentd.conf")
               #:user "zabbix"
               #:group "zabbix"
               #:environment-variables (list
                   "SSL_CERT_DIR=/run/current-system/profile/etc/ssl/certs"
                   "SSL_CERT_FILE=/run/current-system/profile/etc/ssl/certs/ca-certificates.crt"
                   "PATH=/run/setuid-programs:/run/current-system/profile/bin:/run/current-system/profile/sbin"
                   )
               #:log-file (string-append "/var/log/zabbix-agent.log")))
    (stop #~(make-kill-destructor))
  )))

(define zabbix-service-type (service-type
  (name 'zabbix)
  (extensions
    (list (service-extension shepherd-root-service-type zabbix-shepherd-service)
          (service-extension account-service-type zabbix-account)
          (service-extension activation-service-type zabbix-activation)))
  (default-value '())
  (description "Launch zabbix")))

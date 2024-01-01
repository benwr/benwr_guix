(define-module (benwr packages userherd)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (gnu packages admin))
(define-public userherd
  (package
    (name "userherd")
    (version "0.1.0")
    (source (origin
              (method url-fetch/tarbomb)
              (uri (string-append "https://github.com/benwr/userherd/releases/download/" version "/userherd-" version ".tgz"))
              (sha256 (base32 "0xmmpx34i9zsb48jg148fqm7xnldi63fdb3xll58y1xm1x46pznr"))))
    (build-system copy-build-system)
    (arguments
      (list
        #:install-plan
        #~`(("userherd/" "/bin/"))))
    (inputs (list sudo))
    (description "Run a GNU Shepherd instance for your user")
    (home-page "https://github.com/benwr/userherd")
    (synopsis "Run a GNU Shepherd instance for your user")
    (license cc0)))

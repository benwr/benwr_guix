(define-module (benwr packages userherd)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages admin)
)
(define-public userherd
  (package
    (name "userherd")
    (version "0.2.1")
    (source (origin
              (method url-fetch/tarbomb)
              (uri (string-append "https://github.com/benwr/userherd/releases/download/" version "/userherd-" version ".tgz"))
              (sha256 (base32 "05mzzhywl8w34m9sskiwccfx8602z365l3rnsphmgykmnh0q0d2q"))))
    (build-system copy-build-system)
    (arguments
      (list
        #:install-plan
        #~`(("userherd/" "/bin/"))))
    (propagated-inputs (list daemontools))
    (description "Run a GNU Shepherd instance for your user")
    (home-page "https://github.com/benwr/userherd")
    (synopsis "Run a GNU Shepherd instance for your user")
    (license cc0)))

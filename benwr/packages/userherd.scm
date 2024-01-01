(define-module (benwr packages userherd)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (gnu packages base)
)
(define-public userherd
  (package
    (name "userherd")
    (version "0.1.2")
    (source (origin
              (method url-fetch/tarbomb)
              (uri (string-append "https://github.com/benwr/userherd/releases/download/" version "/userherd-" version ".tgz"))
              (sha256 (base32 "1rgl2p1ydb6hn667czqqkfqc3aj9035arvjz3h8j6z8qdh9qq6w6"))))
    (build-system copy-build-system)
    (arguments
      (list
        #:install-plan
        #~`(("userherd/" "/bin/"))))
    (propagated-inputs (list coreutils))
    (description "Run a GNU Shepherd instance for your user")
    (home-page "https://github.com/benwr/userherd")
    (synopsis "Run a GNU Shepherd instance for your user")
    (license cc0)))

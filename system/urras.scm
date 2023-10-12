;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules
  (gnu)
  (nongnu packages linux)
  (nongnu system linux-initrd)
  (benwr packages tailscale)
  (benwr services tailscale)
  (guix gexp)
  (guix packages)
  (gnu services)
  )
(use-package-modules file-systems linux)
(use-service-modules cups networking ssh xorg linux shepherd)


(operating-system
  (kernel linux-6.1)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  (locale "en_US.utf8")
  (timezone "America/Los_Angeles")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "urras")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "ben")
                  (comment "Ben Weinstein-Raun")
                  (group "users")
                  (home-directory "/home/ben")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))

  ;; Packages installed system-wide.  Users can also install packages
  ;; under their own account: use 'guix search KEYWORD' to search
  ;; for packages and 'guix install PACKAGE' to install a package.
  (packages (append (list (specification->package "i3-wm")
                          (specification->package "i3status")
                          (specification->package "dmenu")
                          (specification->package "st")
                          (specification->package "nss-certs")
			  (specification->package "tailscale"))
                    %base-packages))

  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.
  (services
   (append (list ;; To configure OpenSSH, pass an 'openssh-configuration'
                 ;; record as a second argument to 'service' below.
                 (service openssh-service-type)
		 (service dhcp-client-service-type)
		 (service tailscaled-service-type)
		 )

	   ;; This is the list of services we
	   ;; are appending to.
	   (modify-services
	     %base-services
	     (guix-service-type config =>
				(guix-configuration
				  (inherit config)
				  (substitute-urls
				    (append (list "https://substitutes.nonguix.org") %default-substitute-urls))
				  (authorized-keys
				    (append
				      (list
					(plain-file
					  "non-guix.pub"
					  "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
				      %default-authorized-guix-keys)))))))
  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets (list "/dev/sda"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
                        (target (uuid
                                 "38ef7ce8-0104-444c-9cf8-dbb2b84ea8ca")))
		      (swap-space
			(target "/dev/sdb1"))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid
                                  "5e739762-62c6-4f7a-9318-cfd404a1d172"
                                  'ext4))
                         (type "ext4")) %base-file-systems)))

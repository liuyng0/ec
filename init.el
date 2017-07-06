;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
;; (package-initialize)

(add-to-list 'load-path user-emacs-directory)
(setq warning-suppress-types '((initialization)))
(require 'init-system-check)

(let ((is-amazon-machine "0")
      (is-mac-machine "0"))
  (when *is-mac-machine* (setq is-mac-machine "1"))
  (when *is-amazon-machine* (setq is-mac-machine "1"))
  (setq custom-file (format "~/.emacs.d/custom-%s-%s.el"  is-amazon-machine is-mac-machine))
  (when (and (not (file-exists-p custom-file)) (file-exists-p "~/.emacs.d/custom.el"))
    (rename-file "~/.emacs.d/custom.el" custom-file)))

(setq use-theme "none")

(when *is-mac-machine*
  (setq use-theme "sanityinc-tommorrow"))
(when *is-amazon-linux*
  (setq use-theme "sanityinc-tommorrow"))

(when (equal use-theme "none")
  (setq global-background-color "#F5F5F5")
  (setq global-foreground-color "Black"))
(when (equal use-theme "paper")
  (setq global-background-color "#F1F1D4")
  (setq global-foreground-color "Black"))

(when (equal use-theme "sanityinc-tommorrow")
  (setq global-background-color "#2D2D2D"
        global-foreground-color "#CCCCCC"
        ansi-color-faces-vector [default bold shadow italic underline bold bold-italic bold]
        ansi-color-names-vector (vector "#c5c8c6" "#cc6666" "#b5bd68" "#f0c674" "#81a2be" "#b294bb" "#8abeb7" "#1d1f21")))

(when (equal use-theme "solarized")
  (setq global-background-color nil
        global-foreground-color nil)
  (add-to-list 'custom-theme-load-path "~/.emacs.d/site-lisp/emacs-color-theme-solarized/")
  (load-theme 'solarized t))

(setq warning-suppress-types '((initialization)))

(require 'init-system-check)

(require 'init-server)

(require 'init-elpa)
(require 'init-path)
(require 'init-benchmarking)

(require 'init-theme)

(require-package 'wgrep)
(require-package 'project-local-variables)
(require-package 'diminish)
(require-package 'scratch)
(require-package 'mwe-log-commands)
(require-package 'regex-tool)

(require 'init-util-functions)
(require 'init-fonts)
(require 'init-locales)
(require 'init-tidy)
(require 'init-ibuffer)
(require 'init-uniquify)
(require 'init-fci)
(require 'init-editing-utils)

(require 'init-recentf)
(require 'init-ido)
;; FIXME: seems no-flet not compatible with other packages.
;; (require 'kill-ring-ido)

(require 'init-sessions)

(require 'init-maxframe)
(require 'init-windows)
(when *is-linux-system-p*
  (maximize-frame "Emacs::IDE"))
(when *is-windows-system-p*
  (w32-maximize-frame))


;; heavy configures follows
(require 'init-yasnippet)
(require 'init-auto-complete)
(require 'init-python)
;;(require 'init-helm)
;;(require 'init-anything)
(require 'init-ruby)

;; c++ configuration
(require 'init-cc-mode)
(require 'init-smart-compile)
(require 'init-smart-run)


;; org-mode configuration
(require 'init-org)
(require 'init-org-publish-settings)
;; (require 'init-org-remember)

(require 'init-keybind)
(require 'init-cedet)
(require 'init-cmake)


(require 'init-image-support)

;; (require 'init-w32-symlinks)
;; (require 'init-groovy)
(require 'init-glsl-mode)
;; (require 'init-lua)

(require 'init-magit)
(require 'init-latex)
(require 'init-openwith)
;; (require 'init-cnblogs)
(require 'init-handy)
(require 'init-js)
(require 'init-ruhoh)

;;; deprecated from windows
;; (require 'init-topcoder)

(require 'init-lisps)
(require 'init-rainbow-delimiters)


;; (require 'init-metapost)
(require 'init-pandoc)

(require 'important-parameter-settings)
;; (require 'init-chrome-emacs)

(require 'init-load-snippets)
(require 'init-sort-dired)


(require 'init-dired)
(require 'init-uniform-env)


(require 'init-neotree)
(require 'init-smali)
(require 'init-cc-format)

(require 'init-groovy)

(require 'init-logcat-mode)
(require 'init-markdown-mode)
(require 'init-yml-mode)

(require 'init-browse-kill-ring)

(put 'erase-buffer 'disabled nil)
 
(load-file custom-file)

;;;(when (not *is-mac-machine*)
(require 'init-system-default-frame-alist)
;;;)

;; !!!!! put the term code the last !!!!!!!!!!!!
;; import the multi-term function to linux.
(when (or *is-linux-system-p* *is-mac-machine*) 
  (add-to-list 'load-path (concat user-emacs-directory "term"))
  (require 'term-inside-ide-init))

;; (when *is-linux-system-p*
;;   (require 'init-ibus))

(require 'init-dmesg-mode)
(require 'init-dictionary)

(when (and *is-mac-machine* *is-mac-machine*)
  (setq shell-file-name "/bin/bash"))

(require 'init-work-with-repo)
(require 'init-grok)

(require 'init-ediff-binary)

(when (and *is-amazon-linux*)
  (add-to-list 'exec-path "/usr/share-2/bin")
  (require 'init-amazon-linux))


(require 'init-patch-buffer)
(require 'init-json)
(require 'init-confluence)
(require 'init-protobuf)

(require 'init-applescript-mode)
(require 'init-custom-compile)
(require 'init-preview-org)
(require 'init-flycheck)
(require 'init-swift)

(when (file-exists-p "~/.emacs.d/init-private-custom.el")
  (require 'init-private-custom))

(defun make-shell-command-key-lambda (command)
  `(lambda () (interactive)
     (if *is-mac-machine*
         (shell-command ,command)
       (ssh-shell-command ,command)))
  )

(global-set-key "\C-\M-g" (make-shell-command-key-lambda "open \"/Applications/Google Chrome.app/\""))
(global-set-key "\C-\M-x" (make-shell-command-key-lambda "open \"/Applications/Xcode.app/\""))
(global-set-key "\C-\M-t" (make-shell-command-key-lambda "open \"/Applications/iTerm.app/\""))
(global-set-key "\C-\M-l" (make-shell-command-key-lambda "open \"/Applications/Microsoft Lync.app/\""))
(global-set-key "\C-\M-o" (make-shell-command-key-lambda "open \"/Applications/Microsoft Outlook.app/\""))
(global-set-key "\C-\M-p" (make-shell-command-key-lambda "open \"/Applications/Preview.app/\""))
(define-key emacs-lisp-mode-map "\C-\M-x" nil)
(define-key org-mode-map "\C-\M-t" nil)
(define-key paredit-mode-map "\C-\M-p" nil)

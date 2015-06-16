(require 'cc-mode)
(add-to-list 'load-path "~/.emacs.d/site-lisp")

(require 'google-c-style)
(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

(add-hook 'c-mode-common-hook
          (lambda ()
            (c-toggle-auto-hungry-state 1)
            (c-toggle-auto-newline 1)
            ))

;;; use the // comment in c code.
(add-hook 'c-mode-hook
          (lambda () (setq comment-start "// "
                           comment-end "")))

;;; automatic insert matched pairs
(add-hook 'c-mode-common-hook
          (lambda ()
            (setq skeleton-pair t)
            (local-set-key (kbd "(") 'skeleton-pair-insert-maybe)
            (local-set-key (kbd "[") 'skeleton-pair-insert-maybe)
            (local-set-key (kbd "\"") 'skeleton-pair-insert-maybe)
            (local-set-key (kbd "{") 'skeleton-pair-insert-maybe)
            ;;(local-set-key (kbd "{") (lambda () (interactive) (skeleton-pair-insert-maybe) (newline-and-indent)))))
            ))

;;; gdb many windows
(setq gdb-many-windows t)

;; when entering gud mode/kill the gud buffer, change some minor mode.
(defun my-gud-mode-entering-hook()
  ;; (ecb-deactivate)
  (tool-bar-mode 1)
  (gud-tooltip-mode 1)
  (global-semantic-tag-folding-mode -1))
(defun my-gud-kill-buffer-hook()
  (if (eq major-mode 'gud-mode)
      (progn
        (tool-bar-mode -1)
        (gud-tooltip-mode -1)
        (global-semantic-tag-folding-mode 1)
        ;; (ecb-activate)
        )))
(add-hook 'gud-mode-hook 'my-gud-mode-entering-hook)
(add-hook 'kill-buffer-hook 'my-gud-kill-buffer-hook)

;; add compilation mode hook for auto truncate lines.
(add-hook 'compilation-mode-hook
	  (lambda () (interactive) (toggle-truncate-lines -1)))

;;; ----------------------------------------------------------------------------
;;; c++-11 font lock
;;; ----------------------------------------------------------------------------
(require 'font-lock)
(defun --copy-face (new-face face)
  "Define NEW-FACE from existing FACE."
  (copy-face face new-face)
  (eval `(defvar ,new-face nil))
  (set new-face new-face))

(--copy-face 'font-lock-label-face  ; labels, case, public, private, proteced, namespace-tags
	     'font-lock-keyword-face)
(--copy-face 'font-lock-doc-markup-face ; comment markups such as Javadoc-tags
	     'font-lock-doc-face)
(--copy-face 'font-lock-doc-string-face ; comment markups
	     'font-lock-comment-face)

(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)

(add-hook 'c++-mode-hook
	  '(lambda()
	     (font-lock-add-keywords
	      nil '(;; complete some fundamental keywords
		    ("\\<\\(void\\|unsigned\\|signed\\|char\\|short\\|bool\\|int\\|long\\|float\\|double\\)\\>" . font-lock-keyword-face)
		    ;; add the new C++11 keywords
		    ("\\<\\(alignof\\|alignas\\|constexpr\\|decltype\\|noexcept\\|nullptr\\|static_assert\\|thread_local\\|override\\|final\\)\\>" . font-lock-keyword-face)
		    ("\\<\\(char[0-9]+_t\\)\\>" . font-lock-keyword-face)
		    ;; PREPROCESSOR_CONSTANT
		    ("\\<[A-Z]+[A-Z_]+\\>" . font-lock-constant-face)
		    ;; hexadecimal numbers
		    ("\\<0[xX][0-9A-Fa-f]+\\>" . font-lock-constant-face)
		    ;; integer/float/scientific numbers
		    ("\\<[\\-+]*[0-9]*\\.?[0-9]+\\([ulUL]+\\|[eE][\\-+]?[0-9]+\\)?\\>" . font-lock-constant-face)
		    ;; user-types (customize!)
		    ("\\<[A-Za-z_]+[A-Za-z_0-9]*_\\(t\\|type\\|ptr\\)\\>" . font-lock-type-face)
		    ("\\<\\(xstring\\|xchar\\)\\>" . font-lock-type-face)
		    ))
	     ) t)
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

(defun cpplint-analyze()
  (interactive)
  (compile (format "python %s/.emacs.d/site-python/cpplint.py  %s"
                         (getenv "HOME")
                         (buffer-file-name))))
(add-hook 'c++-mode-hook
          (lambda() (local-set-key "\C-c\C-l" 'cpplint-analyze)))
(provide 'init-cc-mode)

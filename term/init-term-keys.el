(require 'multi-term)
(defun disabled-return()
  (interactive)
  (message "disabled return key"))

(defvar-local term--uuid nil "Terminal UUID")

(defun generate-random-uuid ()
  "Generate a random UUID.
Example of a UUID: 1df63142-a513-c850-31a3-535fc3520c3d

WARNING: this is a simple implementation. The chance of generating the same UUID is much higher than a robust algorithm.."
  (interactive)
  (format "%04x%04x-%04x-%04x-%04x-%06x%06x"
          (random (expt 16 4))
          (random (expt 16 4))
          (random (expt 16 4))
          (random (expt 16 4))
          (random (expt 16 4))
          (random (expt 16 6))
          (random (expt 16 6)) ) )

(setq my-extra-needed-key
      '(
        ;; ("C-a" . move-beginning-of-line)
        ;; ("C-e" . move-end-of-line)
        ;; ("C-@" . set-mark-command)
        ("M-w" . kill-ring-save)
        ;; ("C-k" . kill-line)
        ;; ("C-b" . term-send-left)
        ;; ("C-f" . term-send-right)
        ("C-u" . universal-argument)
        ("C-c C-k" . term-line-mode)
        ("C-c C-z" . term-quit-subjob)
        ([(return)] . (lambda()(interactive) (term-send-raw-string "\C-j")))
        ))

(dolist (pair my-extra-needed-key)
  (add-to-list 'term-bind-key-alist pair))

;; (global-set-key "\M-n" 'tabbar-forward)
;; (global-set-key "\M-p" 'tabbar-backward)

(define-key term-mode-map "\C-c\C-k" 'term-toggle-between-modes)

;; setting keys \C-z + i(which from 0 to max-terminal-count) to switch to the the ith term frame
(defconst max-terminal-count 9)
(defun uf-switch-to-term-i ()
  (interactive)
  (let ((num (string-to-number
              (char-to-string (read-char "The terminal order (1-9):")))))
    (update-terms-name)
    (let (tn)
      (when
          (setq tn (nth (1- num) (if (fboundp 'multi-term-list)
                                (multi-term-list)
                              multi-term-buffer-list)))
        (switch-to-buffer tn)))))

(setq multi-term-buffer-name "TM")
(defvar term-name-template "*TM<1>*")

(defun send-to-all-terminal ()
  (interactive)
  (let ((comm (read-string "Input the command to send to all terminal: ")))
    (dolist (term-buf multi-term-buffer-list)
      (with-current-buffer term-buf
        (term-send-raw-string (format "%s\n" comm))))))

(defun update-terms-name ()
  "update all terminal names"
  (dotimes (i (length multi-term-buffer-list))
    (let* ((buf (nth i multi-term-buffer-list))
           (bufname (buffer-name buf))
           (order  (1+ i)))
      (with-current-buffer buf
        (rename-buffer (replace-regexp-in-string "<[0-9]*>" (format "<%d>" order) bufname))))))

(defun move-terminal-as-nth ()
  (interactive)
  (when (not (eq 'term-mode major-mode))
    (error "only use this command with term-mode buffer"))
  (let ((n (read-number
            (format
             "Please enter the number you want to move this terminal to be nth (1-%d): "
             (length multi-term-buffer-list))))
        (cur-buf (current-buffer))
        (temp-list '())
        (old-list multi-term-buffer-list))
    (setq old-list (delete (current-buffer) old-list))
    (dotimes (i (1- n))
      (add-to-list 'temp-list (car old-list) t)
      (setq old-list (cdr old-list)))
    (add-to-list 'temp-list cur-buf t)
    (setq temp-list (append temp-list old-list))
    (setq multi-term-buffer-list temp-list)
    
    ))

(defun move-terminal-as-first ()
  (interactive)
  (when (not (eq 'term-mode major-mode))
    (error "only use this command with term-mode buffer"))
  (setq multi-term-buffer-list (delete (current-buffer) multi-term-buffer-list))
  (setq multi-term-buffer-list (add-to-list 'multi-term-buffer-list (current-buffer)))
  (update-terms-name))

(defadvice multi-term (around multi-term-ad)
  (when (>= (length multi-term-buffer-list) max-terminal-count)
    (error "too many terminal now, try to reuse!"))
  (let* ((random-uuid (generate-random-uuid))
         (process-environment
          (nconc
           (list (format "TERM_UUID=%s" random-uuid))
           process-environment)))
    ad-do-it
    (update-terms-name)
    (setq-local term--uuid random-uuid)))
(ad-activate 'multi-term)

(defadvice term-paste (around check-paste-length)
  (when (> (length (current-kill 0)) 1024)
    (error "the item to paste is too long"))
  ad-do-it)
(ad-activate 'term-paste)

(defun term-prefix (buf)
  (substring (buffer-name buf) 0 (length term-name-template)))

(defun uf-send-command-to-term (command &optional switch-to-buffer-p)
  (let ((term-buf nil))
    (catch 'found
      (dolist (buf-win (window-list))
        (when (and (eq 'term-mode (with-current-buffer (window-buffer buf-win)
                                    major-mode))
                   (not (eq (window-buffer buf-win) (current-buffer))))
          (setq term-buf (window-buffer buf-win))
          (throw 'found term-buf))))
    (when (not term-buf)
      (setq term-buf (get-buffer (ido-completing-read "Choose A Term Buffer: " (mapcar (lambda (para) (buffer-name para)) multi-term-buffer-list)))))
    (with-current-buffer term-buf
      (term-send-raw-string command))
    (when switch-to-buffer-p
        (switch-to-buffer-other-window term-buf)
      (end-of-buffer))))

(defun uf-send-cwd-to-term ()
  (interactive)
  (let ((cwd default-directory))
    (uf-send-command-to-term (format "cd %s\n" cwd) t)))

(defun compile-with-term ()
  (interactive)
  (let ((cwd default-directory)
        (compile-command (read-string "Compile Command: ")))
    (uf-send-command-to-term (format "cd %s && %s 2>&1 | tee compile.log\n" cwd compile-command) nil)
    (catch 'compile-file-generated
      (dotimes (time 10)
        (if (file-exists-p "compile.log")
          (throw 'compile-file-generated t)
          (sleep-for 0.1))))
    (find-file-other-window "compile.log")
    (compilation-mode)))

(defconst *temp-cwd-exchange-file* "~/.temp-cwd-exchange-file")

(defun uf-watch-current-directory ()
  (interactive)
  (when (not (eq 'term-mode major-mode))
    (error "only use this command with term-mode buffer"))
  (let ((path default-directory))
    (find-file-other-window path)))

(defun uf-switch-to-term-buffer ()
  (interactive)
  (let ((buffer-list '()))
    (dolist (term multi-term-buffer-list)
             (add-to-list 'buffer-list (buffer-name term)))
    (switch-to-buffer (get-buffer  (ido-completing-read "Switch to Term: " buffer-list)))))

(defun uf-clear-prompt-command ()
  (interactive)
  (when (not (eq 'term-mode major-mode))
    (error "only use this command with term-mode buffer"))
  (term-send-raw-string (format "export PROMPT_COMMAND=__prompt_command\n")))

(defun get-term-buffer (term-id)
  (let (buf)
    (dolist (term multi-term-buffer-list)
      (with-current-buffer term
        (when (and (equal term--uuid term-id))
          (setq buf term))))
    buf))

(defun _terminal_fields (&optional term-id)
  (interactive)
  (with-current-buffer (if term-id (get-term-buffer term-id) (current-buffer))
    (let* ((index 0)
           (buf-name (buffer-name))
           (buf-len (length buf-name))
           (field-str-table (make-hash-table :test 'equal)))
      (while (and (>= index 0) (< index buf-len)
                  (string-match "\\\[\\(.*?\\):\\(.*?\\)\\\]" buf-name index))
        (let ((key (match-string 1 buf-name))
              (val (match-string 2 buf-name))
              (str (match-string 0 buf-name)))
          (puthash key val field-str-table)
          (setq index (+ index (length str)))))
      field-str-table)))

(defun _make_buffer_name (opr &optional term-id field-str-table)
  "OPR is either 'clear or 'add,
if it's 'clear and FIELD-STR-TABLE is not specified, then all fields will be cleared.
if it's add, then field-str-table must be specified, and it will be sorted and append to buffer name.
"
  (interactive)
  (with-current-buffer (if term-id (get-term-buffer term-id) (current-buffer))
    (let ((fst (or field-str-table (_terminal_fields term--uuid)))
          (buf-name (buffer-name))
          (lst nil)
          (append-name ""))
      (if (eq 'clear opr)
          (maphash (lambda (k v)
                     (setq buf-name
                           (replace-regexp-in-string
                            (regexp-quote (format "[%s:%s]" k v)) "" buf-name)))
                   fst)
        (or (eq 'add opr) (error "the opr should be add or clear"))
        (maphash
         (lambda (k v)
           (push (list k v) lst))
         fst)
        (sort lst (lambda (a b) (string< (car a) (car b))))
        (dolist (x lst)
          (setq append-name (format "%s[%s:%s]" append-name (car x) (cadr x))))
        (setq buf-name (concat buf-name append-name)))
      (rename-buffer buf-name))))

;; TODO: check if clear is needed.
(defun uf-term-rename-buffer (clear)
  (interactive "P")
  (when (not (eq 'term-mode major-mode))
    (error "only use this command with term-mode buffer"))
  (let ((field-str-table (_terminal_fields term--uuid))
        (field (read-string "Field: "))
        (name (read-string "Name: "))
        lst)
    (if (equal name "")
        ;; remove the field
        (when (gethash field field-str-table)
          (remhash field field-str-table))
      (puthash field name field-str-table))
    (_make_buffer_name 'clear term--uuid)
    (_make_buffer_name 'add term--uuid field-str-table)))

(defun uf-send-current-line-command-to-term ()
  (interactive)
  (let ((command
         (cu-strip-string
          (buffer-substring-no-properties (line-beginning-position) (line-end-position))
          t t)))
    (when (y-or-n-p (format "Sending command to terminal:\n [%s]\n" command))
      (uf-send-command-to-term (concat command "\n")))))

(global-unset-key "\C-z")
(cu-set-key-bindings global-map "\C-z"
                     '((?c . multi-term)
                       (?n . multi-term-next)
                       (?p . multi-term-prev)
                       (?g . uf-send-cwd-to-term)
                       (?w . uf-watch-current-directory)
                       (?r . uf-term-rename-buffer)
                       (?s . uf-switch-to-term-buffer)
                       (?p . uf-clear-prompt-command)
                       (?l . uf-send-current-line-command-to-term)
                       (?i . uf-switch-to-term-i)
                       (?j . cu-open-link)))

(provide 'init-term-keys)


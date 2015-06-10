;;----------------------------------------------------------------------------
;; Navigate window layouts with "C-c <left>" and "C-c <right>"
;;----------------------------------------------------------------------------
(winner-mode 1)



;; Make "C-x o" prompt for a target window when there are more than 2
(require-package 'switch-window)
(require 'switch-window)
(setq switch-window-shortcut-style 'alphabet)


;;----------------------------------------------------------------------------
;; When splitting window, show (other-buffer) in the new window
;;----------------------------------------------------------------------------
(defun split-window-func-with-other-buffer (split-function)
  (lexical-let ((s-f split-function))
    (lambda ()
      (interactive)
      (funcall s-f)
      (set-window-buffer (next-window) (other-buffer)))))

(global-set-key "\C-x2" (split-window-func-with-other-buffer 'split-window-vertically))
(global-set-key "\C-x3" (split-window-func-with-other-buffer (lambda() (split-window-right 83))))


;;----------------------------------------------------------------------------
;; Rearrange split windows
;;----------------------------------------------------------------------------
(defun split-window-vertically-instead ()
  (interactive)
  (save-excursion
    (delete-other-windows)
    (funcall (split-window-func-with-other-buffer 'split-window-vertically))))

(defun split-right-at-83-column(arg)
  (interactive "P")
  (delete-other-windows)
  (let ((width 83))
    (when (and *is-amazon-machine*
               (window-system))
      (setq width 95))
    (if arg
        (split-window-right (- width))
      (split-window-right width))))

(defun split-window-horizontally-instead ()
  (interactive)
  (save-excursion
    (delete-other-windows)
    (funcall
     (split-window-func-with-other-buffer (lambda() (split-window-right 83))))))

(defconst alpha-list '((85 50) (100 100)))
(defun window-cycle-alpha-parameter ()
  (interactive)
  (set-frame-parameter (selected-frame) 'alpha (car alpha-list))
  (setq alpha-list (list (cadr alpha-list) (car alpha-list)))
  )

(global-set-key [(f12)] 'window-cycle-alpha-parameter)
(global-set-key "\C-x|" 'split-window-horizontally-instead)
(global-set-key "\C-x_" 'split-window-vertically-instead)

(global-set-key "\C-x9" 'split-right-at-83-column)
(provide 'init-windows)

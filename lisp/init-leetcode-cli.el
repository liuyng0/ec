(defun lc-get-next-unsolved-problem ()
  (interactive)
  (cu-strip-string
   (shell-command-to-string
    "leetcode list -q LD | tac | head -1 | cut -d \"[\" -f 2 | cut -d \"]\" -f 1")
   t t))

(defvar lc-home-dir (format "%s/work/lc" (getenv "HOME")))

(defun lc-get-source-for-next-problem ()
  (interactive)
  (let* ((next-p (lc-get-next-unsolved-problem))
         (check-file-command (format "ls %s/%s.*" lc-home-dir next-p)))
    (if (equal (shell-command check-file-command) 0)
        (cu-strip-string (shell-command-to-string check-file-command) t t)
      (cu-strip-string
       (shell-command-to-string
        (format "leetcode show %s -gx -l cpp -o %s | grep \"Source Code\" | cut -d \":\" -f 2"
                next-p lc-home-dir))))))

(defun lc-open-next-problem ()
  (interactive)
  (find-file-other-window (lc-get-source-for-next-problem)))

(provide 'init-leetcode-cli)

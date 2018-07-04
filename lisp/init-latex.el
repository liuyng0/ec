(require-package 'auctex)
(remove-hook 'LaTeX-mode-hook
 (lambda()
   (push '("XeLaTeX" "%`xelatex%(mode)%' %t" TeX-run-TeX nil t) TeX-command-list)
   (push '("XeLaTeX(minted)" "%`xelatex%(mode) -shell-escape %' %t" TeX-run-TeX nil t)
    TeX-command-list)
   (setq TeX-command-default "XeLaTeX(minted)")
   (setq TeX-save-query nil)
   (setq TeX-show-compilation t)))
(provide 'init-latex)

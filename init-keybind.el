(global-unset-key (kbd "\C-z"))
(global-unset-key (kbd "C-SPC"))

(global-set-key (kbd "C-S-Q") 'vr/query-replace)
(global-set-key (kbd "C-S-R") 'vr/replace)
(global-set-key (kbd "\C-xo") 'switch-window)
(provide 'init-keybind)

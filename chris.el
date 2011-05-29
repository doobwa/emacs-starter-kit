;; zenburn color theme setup
(color-theme-zenburn)
(global-set-key (kbd "<f3>") 'comment-region)
(global-set-key (kbd "<f4>") 'uncomment-region)
(global-set-key (kbd "<f11>") 'toggle-fullscreen)

;; keybinding to start magit gui (for working with git repos)
(global-set-key (kbd "<f2>") 'magit-status) 

;; window configuration
;; don't allow other buffers to open up in this dedicated window
;; http://dfan.org/blog/2009/02/19/emacs-dedicated-windows/
(defun toggle-current-window-dedication ()
 (interactive)
 (let* ((window    (selected-window))
       (dedicated (window-dedicated-p window)))
  (set-window-dedicated-p window (not dedicated))
  (message "Window %sdedicated to %s"
           (if dedicated "no longer " "")
           (buffer-name))))
(global-set-key (kbd "C-x w") 'toggle-current-window-dedication)


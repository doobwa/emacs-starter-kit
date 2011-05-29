;; AUCTeX configuration
(setq TeX-auto-save t)
(setq TeX-parse-self t)

(setq-default TeX-master nil)

;; use pdflatex
(setq TeX-PDF-mode t)

;; use evince for dvi and pdf viewer
;; evince-dvi backend should be installed
(setq TeX-view-program-selection
      '((output-dvi "DVI Viewer")
        (output-pdf "PDF Viewer")
        (output-html "Google Chrome")))
(setq TeX-view-program-list
      '(("DVI Viewer" "evince %o")
        ("PDF Viewer" "evince %o")
        ("Google Chrome" "google-chrome %o")))

(add-hook 'LaTeX-mode-hook 'turn-on-auto-fill)
(add-hook 'LaTeX-mode-hook (lambda () (abbrev-mode +1)))

;; Use F5 to evaluate chunk in .Rnw file
(defun my-ess-hook ()
   "Add my keybindings to ESS mode."
   (local-set-key (kbd "<f5>") 'ess-eval-chunk))
 (add-hook 'ess-mode-hook 'my-ess-hook) 


;; following is for AucTex, adds Sweave commands to 'Command' menu
;; Linking ESS with AucTex
(setq TeX-file-extensions
     '("Snw" "Rnw" "nw" "tex" "sty" "cls" "ltx" "texi" "texinfo"))
(add-to-list 'auto-mode-alist '("\\.Rnw\\'" . Rnw-mode))
(add-to-list 'auto-mode-alist '("\\.Snw\\'" . Snw-mode))

(add-hook 'Rnw-mode-hook
	  (lambda ()
	    (add-to-list 'TeX-command-list
			 '("Sweave" "R CMD Sweave %s" 
			   TeX-run-command nil t :help "Run Sweave") t)
	    (add-to-list 'TeX-command-list
			 '("LatexSweave" "%l \"(%mode)\\input{%s}\"" 
			   TeX-run-TeX nil t :help "Run Latex after Sweave") t)
	    (setq TeX-command-default "Sweave")))

(setq reftex-plug-into-auctex t)

;;; Let M-n w compile a Sweave document via cacheSweaveDriver()
(defun ess-swv-run-in-R2 (cmd &optional choose-process)
  "Run \\[cmd] on the current .Rnw file.  Utility function not called by user."
  (let* ((rnw-buf (current-buffer)))
    (if choose-process ;; previous behavior
    (ess-force-buffer-current "R process to load into: ")
      ;; else
      (update-ess-process-name-list)
      (cond ((= 0 (length ess-process-name-list))
         (message "no ESS processes running; starting R")
         (sit-for 1); so the user notices before the next msgs/prompt
         (R)
         (set-buffer rnw-buf)
         )
        ((not (string= "R" (ess-make-buffer-current))); e.g. Splus, need R
         (ess-force-buffer-current "R process to load into: "))
       ))

    (save-excursion
      (ess-execute (format "require(tools)")) ;; Make sure tools is loaded.
      (basic-save-buffer); do not Sweave/Stangle old version of file !
      (let* ((sprocess (get-ess-process ess-current-process-name))
         (sbuffer (process-buffer sprocess))
         (rnw-file (buffer-file-name))
         (Rnw-dir (file-name-directory rnw-file))
         (Sw-cmd
          (format
           "local({..od <- getwd(); setwd(%S); %s(%S, cacheSweaveDriver()); setwd(..od) })"           
           Rnw-dir cmd rnw-file))
         )
    (message "%s()ing %S" cmd rnw-file)
    (ess-execute Sw-cmd 'buffer nil nil)
    (switch-to-buffer rnw-buf)
    (ess-show-buffer (buffer-name sbuffer) nil)))))


(defun ess-swv-weave2 ()
   "Run Sweave on the current .Rnw file."
   (interactive)
   (ess-swv-run-in-R2 "Sweave"))

(define-key noweb-minor-mode-map "\M-nw" 'ess-swv-weave2)

(provide 'stat-kit-auctex)

;; the following is to interact RefTeX with AUCTeX, see ref card.
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)   ; with AUCTeX LaTeX mode
(add-hook 'latex-mode-hook 'turn-on-reftex)   ; with Emacs latex mode



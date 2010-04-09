;;
;; File .emacs - These commands are executed when GNU emacs starts up.
;;
;; Now, it resides as .emacs.d/init.el


;;; Add all sub-directories under ~/.emacs.d into the load-path
(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((my-lisp-dir "~/.emacs.d/")
	   (default-directory my-lisp-dir))
      (setq load-path (cons my-lisp-dir load-path))
      (normal-top-level-add-subdirs-to-load-path)))

;; Load color theme
(require 'color-theme)
(require 'dark_theme)
(color-theme-initialize)
(dark_theme)

;; Add auto-complete package while loading

;(add-to-list 'load-path "~/.emacs.d/auto-complete/")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/auto-complete/ac-dict")
(ac-config-default)
;(ac-set-trigger-key "TAB")

;; Cause the region to be highlighted and prevent region-based commands
;; from running when the mark isn't active.
 
(pending-delete-mode t)
 (setq transient-mark-mode t)

;; Fonts are automatically highlighted.  For more information
;; type M-x describe-mode font-lock-mode 

(global-font-lock-mode t)

;; Text-based modes (including mail, TeX, and LaTeX modes) are auto-filled.

(add-hook 'text-mode-hook (function turn-on-auto-fill))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; This creates and adds a "Compile" menu to the compiled language modes.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar compile-menu nil
  "The \"Compile\" menu keymap.")

(defvar check-option-modes nil
  "The list of major modes in which the \"Check\" option in the \"Compile\"
menu should be used.")

(defvar compile-menu-modes nil
  "The list of major modes in which the \"Compile\" menu has been installed.
This list used by the function `add-compile-menu-to-mode', which is called by
various major mode hooks.")


;; Create the "Compile" menu.

(if compile-menu
    nil
  (setq compile-menu (make-sparse-keymap "Compile"))
  ;; Define the menu from the bottom up.
  (define-key compile-menu [first-error] '("    First Compilation Error" .
					   first-compilation-error))
  (define-key compile-menu [prev-error]  '("    Previous Compilation Error" .
					   previous-compilation-error))
  (define-key compile-menu [next-error]  '("    Next Compilation Error" .
					   next-error))
  (define-key compile-menu [goto-line]   '("    Line Number..." .
					   goto-line))

  (define-key compile-menu [goto]        '("Goto:" . nil))
  ;;
  (define-key compile-menu [indent-region] '("Indent Selection" .
					     indent-region))

  (define-key compile-menu [make]         '("Make..." . make))

  (define-key compile-menu [check-file]   '("Check This File..." . 
					    check-file))

  (define-key compile-menu [compile]     '("Compile This File..." . compile))
  )


;;; Here are the new commands that are invoked by the "Compile" menu.

(defun previous-compilation-error ()
  "Visit previous compilation error message and corresponding source code.
See the documentation for the command `next-error' for more information."
  (interactive)
  (next-error -1))

(defun first-compilation-error ()
  "Visit the first compilation error message and corresponding source code.
See the documentation for the command `next-error' for more information."
  (interactive)
  (next-error '(4)))

(defvar check-history nil)

(defun check-file ()
  "Run ftnchek on the file contained in the current buffer"
  (interactive)
  (let* ((file-name (file-name-nondirectory buffer-file-name))
	 (check-command (read-from-minibuffer
			 "Check command: "
			 (format "ftnchek %s" file-name) nil nil
			 '(check-history . 1))))
    (save-some-buffers nil nil)
    (compile-internal check-command "Can't find next/previous error"
		      "Checking" nil nil nil)))

(defun make ()
  "Run make in the directory of the file contained in the current buffer"
  (interactive)
  (save-some-buffers nil nil)
  (compile-internal (read-from-minibuffer "Make command: " "make ")
		    "Can't find next/previous error" "Make"
		    nil nil nil))


;;; Define a function to be called by the compiled language mode hooks.

(defun add-compile-menu-to-mode ()
  "If the current major mode doesn't already have access to the \"Compile\"
menu, add it to the menu bar."
  (if (memq major-mode compile-menu-modes)
      nil
    (local-set-key [menu-bar compile] (cons "Compile" compile-menu))
    (setq compile-menu-modes (cons major-mode compile-menu-modes))
    ))


;; And finally, make sure that the "Compile" menu is available in C, C++, and
;; Fortran modes.
(add-hook 'c-mode-hook       (function add-compile-menu-to-mode))
(add-hook 'c++-c-mode-hook   (function add-compile-menu-to-mode))
(add-hook 'c++-mode-hook     (function add-compile-menu-to-mode))

;; This is how emacs tells the file type by the file suffix.
(setq auto-mode-alist
      (append '(("\\.mss$" . scribe-mode))
	      '(("\\.bib$" . bibtex-mode))
	      '(("\\.tex$" . latex-mode))
	      '(("\\.obj$" . lisp-mode))
	      '(("\\.st$"  . smalltalk-mode))
	      '(("\\.Z$"   . uncompress-while-visiting))
	      '(("\\.cs$"  . indented-text-mode))
	      '(("\\.C$"   . c++-mode))
	      '(("\\.cc$"  . c++-mode))
	      '(("\\.icc$" . c++-mode))
	      '(("\\.c$"   . c-mode))
	      '(("\\.y$"   . c-mode))
	      '(("\\.h$"   . c++-mode))
	      auto-mode-alist))

;; Turn off the bell
(setq ring-bell-function (lambda () (message "*beep*")))


;; Use M-x linum-mode to enable line numbers
(require 'linum)

;;
;; Finally look for .customs.emacs file and load it if found

(if "~/.customs.emacs" 
    (load "~/.customs.emacs" t t))

;; Art: added with v. 23.1 to make spacebar complete filenames (8/17/2009)
(progn
 (define-key minibuffer-local-completion-map " " 'minibuffer-complete-word)
 (define-key minibuffer-local-filename-completion-map " " 'minibuffer-complete-word)
 (define-key minibuffer-local-must-match-filename-map " " 'minibuffer-complete-word)) 

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ecb-layout-window-sizes (quote (("amjith1-left-right" (0.16097560975609757 . 0.26666666666666666) (0.16097560975609757 . 0.5333333333333333) (0.16097560975609757 . 0.13333333333333333) (0.17073170731707318 . 0.9333333333333334)))))
 '(ecb-options-version "2.40")
 '(org-agenda-files (quote ("~/org/test.org")))
 '(ecb-windows-width 0.2)
 '(inhibit-startup-screen t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

;; cedet configuration

(load-file "~/.emacs.d/site-lisp/cedet-1.0pre7/common/cedet.el")
;(global-ede-mode 1)                      ; Enable the Project management system
(semantic-load-enable-excessive-code-helpers)      ; Enable prototype help and smart completion
(setq senator-minor-mode "SN")
(setq semantic-imenu-auto-rebuild-directory-indexes nil)
(global-srecode-minor-mode 1)            ; Enable template insertion menu
(global-semantic-mru-bookmark-mode 1)
(require 'semantic-decorate-include)
;; smart completion 
(require 'semantic-ia)
(global-semantic-stickyfunc-mode -1)


(setq-mode-local c-mode semanticdb-find-default-throttle
                 '(project unloaded system recursive))
(setq-mode-local c++-mode semanticdb-find-default-throttle
                 '(project unloaded system recursive))
 
(require 'eassist)
;; customisation of modes
(defun amjith/cedet-hook ()
  (local-set-key [(control return)] 'semantic-ia-complete-symbol-menu)
  (local-set-key "\C-c?" 'semantic-ia-complete-symbol)
  ;;
  (local-set-key "\C-c>" 'semantic-complete-analyze-inline)
  (local-set-key "\C-c=" 'semantic-decoration-include-visit)
 
  (local-set-key "\C-cj" 'semantic-ia-fast-jump)
  (local-set-key "\C-cq" 'semantic-ia-show-doc)
  (local-set-key "\C-cs" 'semantic-ia-show-summary)
  (local-set-key "\C-cp" 'semantic-analyze-proto-impl-toggle)
  )

(add-hook 'c-mode-common-hook 'amjith/cedet-hook)

(defun amjith/c-mode-cedet-hook ()           ; Enable auto-completion when a . or > is pressed (useful for class member completion)
  (local-set-key "." 'semantic-complete-self-insert)
  (local-set-key ">" 'semantic-complete-self-insert)
  (local-set-key "\C-ct" 'eassist-switch-h-cpp)
  (local-set-key "\C-xt" 'eassist-switch-h-cpp)
  (local-set-key "\C-ce" 'eassist-list-methods)
  (local-set-key "\C-c\C-r" 'semantic-symref)
  )
(add-hook 'c-mode-common-hook 'amjith/c-mode-cedet-hook)

; ctags
(require 'semanticdb-ectag)
(semantic-load-enable-primary-exuberent-ctags-support)


;; end cedet config

; Mouse settings
;(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mosue 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time

; C indentation style
(setq c-default-style "bsd"
      c-basic-offset 4)

; Show line and column numbers on status line
(setq line-number-mode t)
(setq column-number-mode t)

; Find line number
(global-set-key   "\M-g"   'goto-line)

; If at beginning of a line, don't make me C-k twice.
(setq kill-whole-line t)

; Saves the current cursor location in a file
(require 'saveplace)
(setq-default save-place t)

;;; Enable vimpulse mode - vim like bindings
(setq viper-want-emacs-keys-in-insert t) ; Use emacs keys in insert mode
(setq viper-auto-indent t)               ; Enable Auto-indent for RET
(require 'vimpulse)


; Find line number
(global-set-key   "\M-g"   'goto-line)
;;; Type 'y' instead of 'yes'
(fset 'yes-or-no-p 'y-or-n-p)

;;;This enables automatic resizing of the minibuffer when its contents
;;;won't fit into a single line.
(condition-case err
    (resize-minibuffer-mode 1)
  (error
   (message "Cannot resize minibuffer %s" (cdr err))))
;;;

;;Hide show stuff - scott little
;; a convenient function to fold or unfold all top-level blocks in
;; an entire file
(defvar my-hs-hide nil "Current state of hideshow for toggling all.")
(defun my-toggle-hideshow-all () "Toggle hideshow all."
  (interactive)
  (setq my-hs-hide (not my-hs-hide))
  (if my-hs-hide
      (hs-hide-all)
    (hs-show-all)))

;;keys for hide-show mode (folding)
(global-set-key "\C-c\C-ft" 'my-toggle-hideshow-all)
(global-set-key "\C-c\C-fh" 'hs-hide-block)
(global-set-key "\C-c\C-fs" 'hs-show-block)
(global-set-key "\C-c\C-fl" 'hs-hide-level)

;;; Highlight during query
(setq query-replace-highlight t)
;;;

;;; Highlight incremental search
(setq search-highlight t)
;;;

;;; Automatically makes the matching paren stand out in color.
(condition-case err
    (show-paren-mode t)
  (error
   (message "Cannot show parens %s" (cdr err))))
;;;

;; Ide-skel 
(require 'tabbar)
(require 'ide-skel)
(global-set-key [C-prior] 'tabbar-backward)
(global-set-key [C-next]  'tabbar-forward)

;; optional, but useful - see Emacs Manual
(partial-completion-mode)
(icomplete-mode)
;; for convenience
;; (global-set-key [f4] 'ide-skel-proj-find-files-by-regexp)
;; (global-set-key [f5] 'ide-skel-proj-grep-files-by-regexp)
;; (global-set-key [f10] 'ide-skel-toggle-left-view-window)
;; (global-set-key [f11] 'ide-skel-toggle-bottom-view-window)
;; (global-set-key [f12] 'ide-skel-toggle-right-view-window)
;; (global-set-key [C-next] 'tabbar-backward)
;; (global-set-key [C-prior]  'tabbar-forward)

;; Org-mode setup

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
(setq org-log-done t)


;; Snippets 
(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/.emacs.d/site-lisp/yasnippet-0.6.1c/snippets/")

;; ido-mode
(require 'ido)
(ido-mode t)


;; ECB related config
(require 'ecb-autoloads)     ; Load ECB after M-x ecb-activate

;; Testing cscope in emacs
(require 'xcscope)
(setq cscope-do-not-update-database t)
;; End of file.

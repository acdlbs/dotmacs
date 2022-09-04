;;; Personal configuration -*- lexical-binding: t -*-

;;mac config setup
(setq mac-command-modifier 'meta)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

 (defadvice text-scale-increase (around all-buffers (arg) activate)
     (with-current-buffer ad-do-it))

(global-display-line-numbers-mode)

;; Add the NonGNU ELPA package archive
(require 'package)
(add-to-list 'package-archives  '("nongnu" . "https://elpa.nongnu.org/nongnu/"))

(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;;;; might need to run the following on fresh install
;; (package-refresh-contents)

;; Load a custom theme
(load-theme 'tango-dark t)

;;; Completion framework
(unless (package-installed-p 'vertico)
  (package-install 'vertico))

;; Enable completion by narrowing
(vertico-mode t)

(define-key vertico-map "?" #'minibuffer-completion-help)
(define-key vertico-map (kbd "M-RET") #'minibuffer-force-complete-and-exit)
(define-key vertico-map (kbd "M-TAB") #'minibuffer-complete)

;; Less rigid completion
(unless (package-installed-p 'orderless)
  (package-install 'orderless))

(setq completion-styles '(orderless basic)
      completion-category-defaults nil
      completion-category-overrides '((file (styles partial-completion))))

(setq read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t
      completion-ignore-case t)

;; Repeat previous vertico session
(global-set-key "\M-R" #'vertico-repeat)
(add-hook 'minibuffer-setup-hook #'vertico-repeat-save)

;; Enable nice vertico completion of things in buffer
;; Use `consult-completion-in-region' if Vertico is enabled.
;; Otherwise use the default `completion--in-region' function.
(setq completion-in-region-function
      (lambda (&rest args)
        (apply (if vertico-mode
                   #'consult-completion-in-region
                 #'completion--in-region)
               args)))

;;;; Improve directory navigation
(with-eval-after-load 'vertico
  (define-key vertico-map "\r" #'vertico-directory-enter)
  (define-key vertico-map "\d" #'vertico-directory-delete-char)
  (define-key vertico-map "\M-\d" #'vertico-directory-delete-word)
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy))

;; Vertico offers the vertico-multiform-mode which allows you to
;; configure Vertico per command or per completion category. The
;; vertico-buffer-mode enables a Helm-like buffer display, which takes
;; more space but also displays more candidates. This verbose display
;; mode is useful for commands like consult-imenu or consult-outline
;; since the buffer display allows you to get a better overview over the
;; entire current buffer. But for other commands you want to keep using
;; the default Vertico display. vertico-multiform-mode solves this
;; configuration problem!

;; Enable vertico-multiform
(vertico-multiform-mode)

;; Configure the display per command.
;; Use a buffer with indices for imenu
;; and a flat (Ido-like) menu for M-x.
(setq vertico-multiform-commands
      '((consult-imenu buffer indexed)
        ;; (execute-extended-command unobtrusive)
	))

;; Configure the display per completion category.
;; Use the grid display for files and a buffer
;; for the consult-grep commands.
(setq vertico-multiform-categories
      '((file grid)
        (consult-grep buffer)))
;; Temporary toggling between the different display modes is
;; possible. Bind the following commands:

(define-key vertico-map "\M-V" #'vertico-multiform-vertical)
(define-key vertico-map "\M-G" #'vertico-multiform-grid)
(define-key vertico-map "\M-F" #'vertico-multiform-flat)
(define-key vertico-map "\M-R" #'vertico-multiform-reverse)
(define-key vertico-map "\M-U" #'vertico-multiform-unobtrusive)

;; silver searcher ag
(unless (package-installed-p 'ag)
  (package-install 'ag
		   ))


;;; Extended completion utilities
(unless (package-installed-p 'consult)
  (package-install 'consult))

(require 'consult)

(global-set-key [rebind switch-to-buffer] #'consult-buffer)
(global-set-key (kbd "C-c j") #'consult-line)
(global-set-key (kbd "C-c i") #'consult-imenu)
(setq read-buffer-completion-ignore-case t
      read-file-name-completion-ignore-case t
      completion-ignore-case t)

;; A safe recommendation is to leave automatic immediate previews
;; enabled in general and disable the automatic preview only for
;; commands, where the preview may be expensive due to file loading.
(consult-customize
 consult-ripgrep consult-git-grep consult-grep
 consult-bookmark consult-recent-file consult-xref
 consult--source-bookmark consult--source-recent-file
 consult--source-project-recent-file
 ;; :preview-key '(:debounce 0.2 any) ;; Option 1: Delay preview
 :preview-key (kbd "M-."))            ;; Option 2: Manual preview

;; In this case one may wonder what the difference is between using
;; an Embark action on the current candidate in comparison to a
;; manually triggered preview. The main difference is that the files
;; opened by manual preview are closed again after the completion
;; session. Furthermore during preview some functionality is
;; disabled to improve the performance, see for example the
;; customization variables consult-preview-allowed-hooks and
;; consult-preview-variables. Files larger than
;; consult-preview-raw-size are previewed literally without syntax
;; highlighting and without changing the major mode. Delaying the
;; preview is also useful for consult-theme, since the theme preview
;; is slow. The delay results in a smoother UI experience.

;; Preview on any key press, but delay 0.5s
(consult-customize consult-theme :preview-key '(:debounce 0.5 any))
;; Preview immediately on M-., on up/down after 0.5s, on any other key after 1s
(consult-customize consult-theme
                   :preview-key
                   (list (kbd "M-.")
                         :debounce 0.5 (kbd "<up>") (kbd "<down>")
                         :debounce 1 'any))

;;;;;;;;;;;;;;; SHOULD I INSTALL EMBARK AND EMBARK_CONSULT?
;; (global-set-key (kbd "M-A") #'marginalia-cycle)  ;; this is already set above
(global-set-key (kbd "C-c h") #'consult-history)
(global-set-key (kbd "C-c m") #'consult-mode-command)
(global-set-key (kbd "C-c k") #'consult-kmacro)
;; C-x bindings (global-set-key (kbd ctl-x-map))
(global-set-key (kbd "C-x M-:") #'consult-complex-command)     ;; orig. repeat-complex-command
(global-set-key (kbd "C-x b") #'consult-buffer)                ;; orig. switch-to-buffer
(global-set-key (kbd "C-x 4 b") #'consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
(global-set-key (kbd "C-x 5 b") #'consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
(global-set-key (kbd "C-x r b") #'consult-bookmark)            ;; orig. bookmark-jump
(global-set-key (kbd "C-x p b") #'consult-project-buffer)      ;; orig. project-switch-to-buffer
;; Custom M-# bindings for fast register access
(global-set-key (kbd "M-#") #'consult-register-load)
(global-set-key (kbd "M-'") #'consult-register-store)          ;; orig. abbrev-prefix-mark (global-set-key (kbd unrelated))
(global-set-key (kbd "C-M-#") #'consult-register)
;; Other custom bindings
(global-set-key (kbd "M-y") #'consult-yank-pop)                ;; orig. yank-pop
(global-set-key (kbd "<help> a") #'consult-apropos)            ;; orig. apropos-command
;; M-g bindings (global-set-key (kbd goto-map))
(global-set-key (kbd "M-g e") #'consult-compile-error)
(global-set-key (kbd "M-g f") #'consult-flymake)               ;; Alternative: consult-flycheck
(global-set-key (kbd "M-g g") #'consult-goto-line)             ;; orig. goto-line
(global-set-key (kbd "M-g M-g") #'consult-goto-line)           ;; orig. goto-line
(global-set-key (kbd "M-g o") #'consult-outline)               ;; Alternative: consult-org-heading
(global-set-key (kbd "M-g m") #'consult-mark)
(global-set-key (kbd "M-g k") #'consult-global-mark)
(global-set-key (kbd "M-g i") #'consult-imenu)
(global-set-key (kbd "M-g I") #'consult-imenu-multi)
;; M-s bindings (search-map)
(global-set-key (kbd "M-s d") #'consult-find)
(global-set-key (kbd "M-s D") #'consult-locate)
(global-set-key (kbd "M-s g") #'consult-grep)
(global-set-key (kbd "M-s G") #'consult-git-grep)
(global-set-key (kbd "M-s r") #'consult-ripgrep)
(global-set-key (kbd "M-s l") #'consult-line)
(global-set-key (kbd "M-s L") #'consult-line-multi)
(global-set-key (kbd "M-s m") #'consult-multi-occur)
(global-set-key (kbd "M-s k") #'consult-keep-lines)
(global-set-key (kbd "M-s u") #'consult-focus-lines)

;; Isearch integration
(global-set-key (kbd "M-s e") #'consult-isearch-history)
(define-key isearch-mode-map (kbd "M-e") #'consult-isearch-history)         ;; orig. isearch-edit-string
(define-key isearch-mode-map (kbd "M-s e") #'consult-isearch-history)       ;; orig. isearch-edit-string
(define-key isearch-mode-map (kbd "M-s l") #'consult-line)                  ;; needed by consult-line to detect isearch
(define-key isearch-mode-map (kbd "M-s L") #'consult-line-multi)            ;; needed by consult-line to detect isearch

;; Minibuffer history
(define-key minibuffer-local-map (kbd "M-s") #'consult-history)                 ;; orig. next-matching-history-element
(define-key minibuffer-local-map (kbd "M-r") #'consult-history)

;; Enable automatic preview at point in the *Completions* buffer. This is
;; relevant when you use the default completion UI.
(add-hook 'completion-list-mode #'consult-preview-at-point-mode)

;; Optionally configure the register formatting. This improves the register
;; preview for `consult-register', `consult-register-load',
;; `consult-register-store' and the Emacs built-ins.
(setq register-preview-delay 0.5
      register-preview-function #'consult-register-format)

;; Optionally tweak the register preview window.
;; This adds thin lines, sorting and hides the mode line of the window.
(advice-add #'register-preview :override #'consult-register-window)

;; Use Consult to select xref locations with preview
(setq xref-show-xrefs-function #'consult-xref
      xref-show-definitions-function #'consult-xref)

;; Optionally configure preview. The default value
;; is 'any, such that any key triggers the preview.
;; (setq consult-preview-key 'any)
;; (setq consult-preview-key (kbd "M-."))
;; (setq consult-preview-key (list (kbd "<S-down>") (kbd "<S-up>")))
;; For some commands and buffer sources it is useful to configure the
;; :preview-key on a per-command basis using the `consult-customize' macro.
(consult-customize
 consult-theme
 :preview-key '(:debounce 0.2 any)
 consult-ripgrep consult-git-grep consult-grep
 consult-bookmark consult-recent-file consult-xref
 consult--source-bookmark consult--source-recent-file
 consult--source-project-recent-file
 :preview-key (kbd "M-."))

;; Optionally configure the narrowing key.
;; Both < and C-+ work reasonably well.
(setq consult-narrow-key "<") ;; (kbd "C-+")

;; Optionally make narrowing help available in the minibuffer.
;; You may want to use `embark-prefix-help-command' or which-key instead.
;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

;; By default `consult-project-function' uses `project-root' from project.el.
;; Optionally configure a different project root function.
;; There are multiple reasonable alternatives to chose from.
  ;;;; 1. project.el (the default)
;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. projectile.el (projectile-project-root)
;; (autoload 'projectile-project-root "projectile")
;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 3. vc.el (vc-root-dir)
;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 4. locate-dominating-file
;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))

(unless (package-installed-p 'marginalia)
  (package-install 'marginalia))

(marginalia-mode)
;; (define-key minibuffer-local-map "\M-A" #'marginalia-cycle)
(global-set-key (kbd "M-A") #'marginalia-cycle)

;;;;;;;;;;;;;;;;; Embark and Embark Consult
(unless (package-installed-p 'embark)
  (package-install 'embark))

(require 'embark)
(global-set-key (kbd "C-.") #'embark-act)         ;; pick some comfortable binding
(global-set-key (kbd "C-;") #'embark-dwim)        ;; good alternative: M-.
(global-set-key (kbd "C-h B") #'embark-bindings) ;; alternative for `describe-bindings'

;; Optionally replace the key help with a completing-read interface
(setq prefix-help-command #'embark-prefix-help-command)

;; Hide the mode line of the Embark live/completions buffers
(add-to-list 'display-buffer-alist
             '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
               nil
               (window-parameters (mode-line-format . none))))

;; Consult users will also want the embark-consult package.
(unless (package-installed-p 'embark-consult)
  (package-install 'embark-consult))

(require 'embark-consult)
(add-hook 'embark-collect-mode #'consult-preview-at-point-mode)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;for ruby dev I use solargraph for LSP ***needs to be installed separately***

(unless (package-installed-p 'inf-ruby)
  (package-install 'inf-ruby))

(autoload 'inf-ruby-minor-mode "inf-ruby" "Run an inferior Ruby process" t)
(add-hook 'ruby-mode-hook 'inf-ruby-minor-mode)

(add-hook 'compilation-filter-hook 'inf-ruby-auto-enter)

;; Automatically pair parentheses
(electric-pair-mode t)

;;; LSP Support
;; (unless (package-installed-p 'eglot)
;;   (package-install 'eglot))

;; (require 'eglot)
;; ;; Enable LSP support by default in programming buffers that support it
;; (defun aiden-ensure-eglot-if-supported ()
;;   (unless (eq 'emacs-lisp-mode major-mode)
;;     (eglot-ensure)))

;; (add-hook 'prog-mode-hook #'aiden-ensure-eglot-if-supported)
;; (add-to-list 'eglot-server-programs '(clojure-mode . ("clojure-lsp")))

;;; Inline static analysis

;; Enabled inline static analysis
(add-hook 'prog-mode-hook #'flymake-mode)

;; Display messages when idle, without prompting
(setq help-at-pt-display-when-idle t)

;; Message navigation bindings
(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "C-c n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "C-c p") #'flymake-goto-prev-error))

;;; Git client
(unless (package-installed-p 'magit)
  (package-install 'magit))

;; Bind the `magit-status' command to a convenient key.
(global-set-key (kbd "C-c g") #'magit-status)

;; Show word-granularity differences within diff hunks
(setq magit-diff-refine-hunk t)

;;; Indication of local VCS changes
(unless (package-installed-p 'diff-hl)
  (package-install 'diff-hl))

;; Enable `diff-hl' support by default in programming buffers
(add-hook 'prog-mode-hook #'diff-hl-mode)

;;; Clojure Support
(unless (package-installed-p 'clojure-mode)
  (package-install 'clojure-mode))

(unless (package-installed-p 'cider)
  (package-install 'cider))

;;; C# Support
(unless (package-installed-p 'csharp-mode)
  (package-install 'csharp-mode))

;;; Go Support
(unless (package-installed-p 'go-mode)
  (package-install 'go-mode))

;;; Haskell Support
(unless (package-installed-p 'haskell-mode)
  (package-install 'haskell-mode))

;;; JSON Support
(unless (package-installed-p 'json-mode)
  (package-install 'json-mode))

;;; PHP Support
(unless (package-installed-p 'php-mode)
  (package-install 'php-mode))

;;; Rust Support
(unless (package-installed-p 'rust-mode)
  (package-install 'rust-mode))

;;; Typescript Support
(unless (package-installed-p 'typescript-mode)
  (package-install 'typescript-mode))

;;; Docker Tramp Support
(unless (package-installed-p 'docker-tramp)
  (package-install 'docker-tramp))

;;; YAML Support
(unless (package-installed-p 'yaml-mode)
  (package-install 'yaml-mode))

;;; LaTeX support
(unless (package-installed-p 'auctex)
  (package-install 'auctex))
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

;; Enable LaTeX math support
(add-hook 'LaTeX-mode-map #'LaTeX-math-mode)

;; Enable reference mangment
(add-hook 'LaTeX-mode-map #'reftex-mode)

;;; Markdown support
(unless (package-installed-p 'markdown-mode)
  (package-install 'markdown-mode))

;;; Outline-based notes management and organizer
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)

;;; EditorConfig support
(unless (package-installed-p 'editorconfig)
  (package-install 'editorconfig))

;; Enable EditorConfig
(editorconfig-mode t)

;;; Jump to arbitrary positions
(unless (package-installed-p 'avy)
  (package-install 'avy))
(global-set-key (kbd "C-c z") #'avy-goto-word-1)

;; Jump to any open window or frame
(setq avy-all-windows 'all-frames)

;; emacs-bash-completion # this isn't in elpa
;;(add-to-list 'load-path "~/.emacs.d/emacs-bash-completion/")
;;(require 'bash-completion)
;;(bash-completion-setup)

;;; one way to enable eshell completion (from readme in repo)
;; (defun bash-completion-from-eshell ()
;;   (interactive)
;;   (let ((completion-at-point-functions
;;          '(bash-completion-eshell-capf)))
;;     (completion-at-point)))

;; (defun bash-completion-eshell-capf ()
;;   (bash-completion-dynamic-complete-nocomint
;;    (save-excursion (eshell-bol) (point))
;;    (point) t))

;; Backup file location
;; backup in one place. flat, no tree structure
(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))

;; Miscellaneous options
(setq-default major-mode
              (lambda () ; guess major mode from file name
                (unless buffer-file-name
                  (let ((buffer-file-name (buffer-name)))
                    (set-auto-mode)))))
(setq confirm-kill-emacs #'yes-or-no-p)
(setq window-resize-pixelwise t)
(setq frame-resize-pixelwise t)

(global-set-key (kbd "C-x 4 s") #'window-swap-states)

;; preserve cider repl commands
(setq cider-repl-history-file "~/.emacs.d/.cider-repl-hist")

(save-place-mode t)
(savehist-mode t)
(recentf-mode t)
(defalias 'yes-or-no #'y-or-n-p)

(setq ring-bell-function 'ignore)
(setq enable-recursive-minibuffers t)

(desktop-save-mode t)

;; Store automatic customisation options elsewhere
(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(avy editorconfig markdown-mode auctex yaml-mode typescript-mode rust-mode php-mode json-mode haskell-mode go-mode csharp-mode cider clojure-mode diff-hl magit eglot inf-ruby embark-consult embark marginalia consult orderless vertico)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; .emacs --- My custom .emacs file

;;; Commentary:
;;;;;; here's some commentary

;;; Code:
;; .emeacs -- Aidennn
;n;package
;;Add MELPA repository for packages
(require 'package)
(setq package-archives
      '(("elpy" . "http://jorgenschaefer.github.io/packages/")
        ("melpa" . "https://melpa.org/packages/")
        ("gnu" . "http://elpa.gnu.org/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")))
(package-initialize)
(setq tls-checktrust t)
;;Deps
;;helm
(require 'helm)
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "M-x") #'helm-M-x)
(global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
(global-set-key (kbd "C-x C-f") #'helm-find-files)
;;helm tab complete
(define-key helm-map (kbd "TAB") #'helm-execute-persistent-action)
(define-key helm-map (kbd "<tab>") #'helm-execute-persistent-action)
(define-key helm-map (kbd "C-z") #'helm-select-action)
;;;;;;;;;;;;;;
(helm-mode 1)
;;helm projectile
(require 'helm-projectile)
(helm-projectile-on)
;;(helm-projectile 1)
;;(setq projectile-completion-system 'helm)
;;helm-cider
(require 'helm-cider)
(helm-cider-mode 1)
;;helm swoop
(require 'helm-swoop)
;; Change the keybinds to whatever you like :)
(global-set-key (kbd "M-i") 'helm-swoop)
;;projectile
(require 'projectile)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(projectile-mode 1)
;;(projectile-mode +1)
;;magit
(require 'magit)
;;Flycheck
(require 'flycheck)
;; Enable flycheck globally
(global-flycheck-mode)

;; regular auto-complete initialization
(require 'auto-complete-config)
(ac-config-default)

(require 'company)
(global-company-mode t)

;;clojure
(unless (package-installed-p 'clojure-mode)
  (package-install 'clojure-mode))
;; paredit
  (autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
    (add-hook 'emacs-lisp-mode-hook    #'enable-paredit-mode)
    (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
    (add-hook 'ielm-mode-hook             #'enable-paredit-mode)
    (add-hook 'lisp-mode-hook             #'enable-paredit-mode)
    (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)
(add-hook 'clojure-mode-hook #'paredit-mode)
;;ac-cider
(require 'ac-cider)
(add-hook 'cider-mode-hook 'ac-flyspell-workaround)
(add-hook 'cider-mode-hook 'ac-cider-setup)
(add-hook 'cider-repl-mode-hook 'ac-cider-setup)
(eval-after-load "auto-complete"
    '(add-to-list 'ac-modes 'cider-mode))
;;which-key
(require 'which-key)
(which-key-mode)
;;webmode
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(setq web-mode-ac-sources-alist
  '(("css" . (ac-source-css-property))
    ("html" . (ac-source-words-in-buffer ac-source-abbrev))))
;; indium
(unless (package-installed-p 'indium)
  (package-install 'indium))
;;term
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(require 'company)
(require 'company-tern)

(add-to-list 'company-backends 'company-tern)
(add-hook 'js2-mode-hook (lambda ()
                           (tern-mode)
                           (company-mode)))
                           
;; Disable completion keybindings, as we use xref-js2 instead
(define-key tern-mode-keymap (kbd "M-.") nil)
(define-key tern-mode-keymap (kbd "M-,") nil)
;;customizations
(tool-bar-mode -1)
(menu-bar-mode -1)
(global-set-key (kbd "C-c t") 'eshell )
;;theme
(load-theme 'solarized-dark t)

;;auto
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("d91ef4e714f05fff2070da7ca452980999f5361209e679ee988e3c432df24347" "0598c6a29e13e7112cfbc2f523e31927ab7dce56ebb2016b567e1eff6dc1fd4f" default)))
 '(global-company-mode t)
 '(jdee-server-dir "/home/aiden_user/Documents/JdeeServer")
 '(package-selected-npackages
   (quote
    (which-key helm-cider geben-helm-projectile helm-company ac-cider cider clojure-mode paredit flycheck web-mode helm-swoop helm-projectile solarized-theme projectile magit helm)))
 '(package-selected-packages
   (quote
    (python-mode tern-context-coloring tern-auto-complete company-tern indium jdee latex-extra which-key web-mode solarized-theme rjsx-mode paredit magit helm-swoop helm-company helm-cider geben-helm-projectile flycheck add-node-modules-path ac-cider)))
 '(tls-checktrust (quote ask)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(provide 'init)
;;; init ends here

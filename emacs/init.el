(load-file (concat (getenv "HOME_D") "/profile/emacs/pre-init.el"))

(package-initialize)

(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(global-auto-revert-mode t)

(setq inhibit-startup-screen t
      initial-scratch-message nil
      make-backup-files nil
      visible-bell t
      column-number-mode t
      size-indication-mode t
      vc-follow-symlinks t
      disabled-command-function nil)

(setq-default indent-tabs-mode nil)

(add-hook 'before-save-hook 'whitespace-cleanup)

(defalias 'yes-or-no-p 'y-or-n-p)

(use-package avy
  :bind (("C-=" . avy-goto-word-1)
         ("M-g g" . avy-goto-line))
  :init (setq avy-keys '(?a ?r ?s ?t ?d ?h ?n ?e ?i ?o)))

(use-package company
  :init (global-company-mode))

(use-package ediff
  :init (setq ediff-window-setup-function 'ediff-setup-windows-plain))

;; TODO integrate flycheck-color-mode-line and flycheck-pos-tip
(use-package flycheck
  :init (use-package flycheck-haskell
          :init (progn
                  (add-hook 'haskell-mode-hook 'flycheck-mode)
                  (add-hook 'flycheck-mode-hook 'flycheck-haskell-setup))))

(use-package haskell-mode
  :init (progn
          (setq haskell-stylish-on-save t)
          (add-hook 'haskell-mode-hook 'haskell-indentation-mode)
          (add-hook 'haskell-mode-hook 'interactive-haskell-mode)))

(use-package helm
  :init (progn
          (require 'helm-config)
          (setq ido-use-virtual-buffers t
                helm-mode-fuzzy-match t
                helm-completion-in-region-fuzzy-match t))
  :bind (("C-c h" . helm-command-prefix)
         ("M-x" . helm-M-x)
         ("M-s o" . helm-occur)
         ("C-x C-f" . helm-find-files)
         ("C-x b" . helm-buffers-list)))

(use-package helm-descbinds
  :bind ("C-h b" . helm-descbinds))

(use-package helm-git-ls
  :bind ("C-x C-d" . helm-browse-project))

(use-package magit
  :bind (("C-c i" . magit-status)
         ("C-c I" . magit-status))
  :init (progn
          (require 'helm-mode)
          (setq magit-diff-refine-hunk 'all
                magit-completing-read-function 'helm--completing-read-default)))

(use-package menu-bar
  :bind ("C-c m" . menu-bar-mode))

(use-package org-agenda
  :bind ("C-c a" . org-agenda)
  :init (progn
          (setq org-agenda-skip-scheduled-if-done t
                org-agenda-skip-deadline-if-done t)
          (add-hook 'org-agenda-mode-hook (lambda () (setq default-directory org-directory)))))

(use-package org-capture
  :bind ("C-c c" . org-capture))

(use-package paren
  :init (progn
          (setq show-paren-delay 0)
          (show-paren-mode 1)))

(use-package paredit
  :init (add-hook 'emacs-lisp-mode-hook 'paredit-mode))

(use-package recentf
  :init (setq recentf-max-saved-items nil
              recentf-auto-cleanup 10))

(use-package whitespace
  :bind ("C-c w" . whitespace-mode))

(use-package yaml-mode)

(use-package zenburn-theme
  :init (load-theme 'zenburn t))
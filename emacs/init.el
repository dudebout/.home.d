(package-initialize)

(let ((pre-init (concat (getenv "HOME_D") "/profile/emacs/pre-init.el")))
  (when (file-exists-p pre-init)
    (load-file pre-init)))

(require 'home.d-interactives (concat (getenv "HOME_D") "/emacs/home.d-interactives.el"))

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

(setq-default indent-tabs-mode nil
              require-final-newline t)

(add-hook 'before-save-hook 'whitespace-cleanup)

(defalias 'yes-or-no-p 'y-or-n-p)

(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "C-x C-z"))

(defun tmux-default-directory ()
  (interactive)
  (call-process "ct" nil nil nil default-directory))

(bind-key "C-x M-w" 'home.d/rename-current-buffer-file)
(bind-key "C-x M-k" 'home.d/delete-current-buffer-and-delete-file)
(bind-key "M-g M-g" 'home.d/goto-line-with-feedback)
(bind-key "C-c r" 'replace-string)
(bind-key "C-c g" 'rgrep)
;; Make sure that the last letter of the keybinding does not
;; correspond to the letter of the XMonad binding called by ct, else
;; xdotool key does not seem to be called properly / there is an
;; overlap problem. That problem can be fixed with a sleep (not ideal)
;;
;; If using "C-c t" and "Super+t", you would get an error saying that "C-S-t is not defined"
(bind-key "C-c d" 'tmux-default-directory)

;; Not sure that this is such a good idea anyway
;; When this is turned on, we get a message about the latest loaded module instead...
;; (defmacro inhibit-startup-echo-area-message ()
;;   (list 'setq 'inhibit-startup-echo-area-message (getenv "USER")))
;; (inhibit-startup-echo-area-message)


(setq use-package-verbose t)
(require 'use-package)

(use-package ace-window
  :bind ("M-p" . ace-window)
  :init (progn
          (setq aw-keys '(?a ?r ?s ?t ?n ?e ?i ?o))
          (ace-window-display-mode)))

(use-package avy
  :bind (("C-=" . avy-goto-word-1)
         ("M-g g" . avy-goto-line))
  :init (progn
          (setq avy-keys '(?a ?r ?s ?t ?d ?h ?n ?e ?i ?o)) ;; put the keys on the colemak row
          (avy-setup-default))) ;; setup C-' in isearch

(use-package company
  :init (global-company-mode))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-h b" . counsel-descbinds)
         ("C-x C-f" . counsel-find-file)
         ("C-c j" . counsel-git-grep)))

(use-package dante
  :init  (add-hook 'haskell-mode-hook 'dante-mode))

(use-package ediff
  :init (setq ediff-window-setup-function 'ediff-setup-windows-plain))

(use-package elisp-slime-nav
  :init (progn
          (add-hook 'emacs-lisp-mode-hook 'elisp-slime-nav-mode)
          (add-hook 'c-mode-hook 'elisp-slime-nav-mode)))

;; TODO integrate flycheck-color-mode-line and flycheck-pos-tip
(use-package flycheck
  :init (use-package flycheck-haskell
          :init (progn
                  (add-hook 'haskell-mode-hook 'flycheck-mode)
                  (add-hook 'flycheck-mode-hook 'flycheck-haskell-setup)
                  (global-flycheck-mode))))

(use-package god-mode
  :init (global-set-key (kbd "<escape>") 'god-local-mode))

(use-package git-gutter
  :init (global-git-gutter-mode))

(use-package haskell-mode
  :init (progn
          (setq haskell-stylish-on-save t)
          (add-hook 'haskell-mode-hook 'haskell-indentation-mode)
          ;; dante has conflicting install instructions with
          ;; haskell-mode. Ensure the haskell-mode instructions are
          ;; followed when dante is not installed.
          (unless (locate-library "dante")
            (add-hook 'haskell-mode-hook 'interactive-haskell-mode))))

(use-package helm
  :init (progn
          (require 'helm-config)
          (setq ido-use-virtual-buffers t
                helm-mode-fuzzy-match t
                helm-completion-in-region-fuzzy-match t))
  :bind (("C-c h" . helm-command-prefix)
         ("M-s o" . helm-occur)))

(use-package helm-ag
  :init (setq helm-ag-insert-at-point 'symbol)
  :bind (("C-c /" . helm-ag)
         ("C-c s" . helm-ag-project-root)))

(use-package helm-git-ls
  :bind ("C-x C-d" . helm-browse-project))

(use-package hydra)

(use-package ivy
  :bind ("C-x b" . ivy-switch-buffer)
  :init (setq ivy-use-virtual-buffers t))

(use-package macrostep
  :bind ("C-c e" . macrostep-expand))

(use-package magit
  :bind (("C-c i" . magit-status)
         ;; TODO make C-c I chose the directory first
         ("C-c I" . magit-status))
  :init (progn
          (require 'helm-mode)
          (setq magit-delete-by-moving-to-trash nil
                magit-diff-refine-hunk 'all
                magit-completing-read-function 'helm--completing-read-default)))

(use-package menu-bar
  :bind ("C-c m" . menu-bar-mode))

(use-package org-agenda
  :bind ("C-c a" . org-agenda)
  :init (progn
          (setq org-agenda-skip-scheduled-if-done t
                org-agenda-skip-deadline-if-done t
                org-startup-indented t
                org-agenda-custom-commands
                '(("u" alltodo ""
                   ((org-agenda-skip-function
                     (lambda nil
                       (org-agenda-skip-entry-if 'scheduled 'deadline))))
                   (org-agenda-overriding-header "Unscheduled TODO entries: "))))
          (add-hook 'org-agenda-mode-hook
                    (lambda () (setq default-directory org-directory)))))

(use-package org-capture
  :bind ("C-c c" . org-capture))

(use-package org-protocol)

(use-package paren
  :init (progn
          (setq show-paren-delay 0)
          (show-paren-mode 1)))

(use-package paredit
  :init (add-hook 'emacs-lisp-mode-hook 'paredit-mode))

(use-package recentf
  :init (setq recentf-max-saved-items nil
              recentf-auto-cleanup 60))

(use-package smart-mode-line
  ;; consider using powerline and smart-mode-line-powerline-theme
  :init (progn
          (setq sml/no-confirm-load-theme t)
          (smart-mode-line-enable)))

(defun ddb/add-shell-extension (shell &optional ext)
  (let* ((ext (or ext shell))
         (rx (format "\\.%s\\'" ext)))
    (add-to-list 'auto-mode-alist `(,rx . sh-mode))
    ;; Usually do not quote lambda in a hook, as a lambda is self-quoting.
    ;; Here we want to quote it, to force the "evaluation" of the let-bound variables
    (add-hook 'sh-mode-hook `(lambda ()
                               (when (string-match ,rx buffer-file-name)
                                 (sh-set-shell ,shell))))))

(use-package sh-script
  :init (ddb/add-shell-extension "zsh"))

(use-package swiper
  :bind ("C-s" . swiper))

(use-package whitespace
  :bind ("C-c w" . whitespace-mode))

(use-package yaml-mode)

(use-package zenburn-theme
  :init (load-theme 'zenburn t))

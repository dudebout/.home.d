(package-initialize)

(let ((pre-init (concat (getenv "HOME_D") "/profile/emacs/pre-init.el")))
  (when (file-exists-p pre-init)
    (load-file pre-init)))

(require 'home.d-interactives (concat (getenv "HOME_D") "/emacs/home.d-interactives.el"))
(require 'home.d-org (concat (getenv "HOME_D") "/emacs/home.d-org.el"))

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
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

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
  :bind ("M-o" . ace-window)
  :init (progn
          ;; colemak home row, minus n, and o which are reserved
          ;; should consider ordering them by finger strength
          (setq aw-keys '(?a ?r ?s ?t ?d ?h ?e ?i)
                aw-dispatch-always t)
          (ace-window-display-mode)))

(use-package avy
  :bind (("C-=" . avy-goto-word-1)
         ("M-g g" . avy-goto-line)
         ("C-c W" . avy-org-refile-as-child))
  :init (progn
           ;; colemak home row
          (setq avy-keys '(?a ?r ?s ?t ?d ?h ?n ?e ?i ?o))
          ;; setup C-' in isearch
          (avy-setup-default)))

(use-package company
  :init (global-company-mode))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-h b" . counsel-descbinds)
         ("C-x C-f" . counsel-find-file)
         ("C-c j" . counsel-git-grep)))

;; (use-package dante
;;   :init  (progn
;;            (put 'dante-project-root 'safe-local-variable #'stringp)
;;            (add-hook 'haskell-mode-hook 'dante-mode)))
;;
;; .dir-locals.el example
;; ((haskell-mode . ((dante-project-root . "/codemill/dudebout/repos/arc-systems/"))))

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

;;; https://emacs.stackexchange.com/questions/7281/how-to-modify-face-for-a-specific-buffer
;;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Face-Remapping.html
(defun ddb/switch-mode-line-background-on-god-mode ()
  (if god-local-mode
      (progn
        (setq ddb/mode-line-relative-cookie
              (face-remap-add-relative 'mode-line `((:background ,(zenburn-with-color-variables zenburn-red-4)))))
        (setq ddb/mode-line-inactive-relative-cookie
              (face-remap-add-relative 'mode-line-inactive `((:background ,(zenburn-with-color-variables zenburn-red-3))))))
    (progn
      (face-remap-remove-relative ddb/mode-line-relative-cookie)
      (face-remap-remove-relative ddb/mode-line-inactive-relative-cookie))))

(use-package god-mode
  :init (progn
          (global-set-key (kbd "<escape>") 'god-local-mode)
          (eval-after-load 'zenburn-theme
            '(progn
              (add-hook 'god-mode-enabled-hook 'ddb/switch-mode-line-background-on-god-mode)
              (add-hook 'god-mode-disabled-hook 'ddb/switch-mode-line-background-on-god-mode)))))

(use-package git-gutter
  :init (global-git-gutter-mode))

(use-package haskell-mode
  :interpreter ("stack" . haskell-mode)
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

(use-package org
  :defer t
  :init
  (setq org-log-into-drawer t
        org-log-note-clock-out t
        org-startup-indented t
        org-todo-keywords '((type "TODO(t!)"
                                  "WAITING(w@/@)"
                                  "DELEGATED(D@/!)"
                                  "READ(r)" "WATCH(w)"
                                  "|"
                                  "DONE(d!)"
                                  "CANCELED(c@)"))))

(use-package org-agenda
  :bind ("C-c a" . org-agenda)
  :init
  (setq org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t
        org-agenda-start-with-clockreport-mode t
        org-agenda-start-with-log-mode t
        org-agenda-files (list org-directory)
        org-agenda-custom-commands '(("u" alltodo ""
                                      ((org-agenda-skip-function
                                        (lambda ()
                                          (org-agenda-skip-entry-if 'scheduled 'deadline))))
                                      (org-agenda-overriding-header "Unscheduled TODO entries: "))
                                     ("n" "Next actions"
                                      ((agenda "")
                                       (tags "-inbox+ready"
                                             ((org-agenda-skip-function #'home.d/org-agenda-skip-not-next-action)))))))
  (add-hook 'org-agenda-mode-hook
            (lambda () (setq default-directory org-directory)))
  :config
  (mapc (lambda (type)
          (setf (alist-get type org-agenda-prefix-format)
                "%-20(home.d/org-agenda-prefix-format) "))
        '(todo agenda tags)))

(use-package org-capture
  :bind ("C-c c" . org-capture)
  :init
  ;; consider merging the inbox into a single tree (what is the purpose of tasks vs notes?)
  (setq org-capture-templates '(("t" "task" entry
                                 (file+olp home.d/capture-file "inbox" "tasks")
                                 "* TODO %?\n%U")
                                ("r" "read" entry
                                 (file+olp home.d/capture-file "inbox" "tasks")
                                 "* READ [[%:link][%:description]]\n%U"
                                 :immediate-finish t)
                                ("w" "watch" entry
                                 (file+olp home.d/capture-file "inbox" "tasks")
                                 "* WATCH [[%:link][%:description]]\n%U"
                                 :immediate-finish t)
                                ("n" "note" entry
                                 (file+olp home.d/capture-file "inbox" "notes")
                                 "* NOTE %?\n%U"))))

(use-package org-clock
  :defer t
  :init
  (setq org-clock-continuously t))

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
          (setq sml/no-confirm-load-theme t
                sml/theme nil
                rm-blacklist '(" God"))
          (sml/setup)))

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
  :init (progn
          (load-theme 'zenburn t)
          (zenburn-with-color-variables
            (set-face-attribute 'sml/minor-modes nil :foreground zenburn-orange))))

;; ;; https://emacs.stackexchange.com/questions/34670/how-does-one-set-input-decode-map-on-gui-frames-in-emacsclient
;;
;; None of the following is enough to reclaim C-m in a new emacsclient

;; (defun ~/setup-C-m (&rest args)
;;   (define-key input-decode-map [?\C-m] [C-m]))

;; (~/setup-C-m)
;; (add-hook 'tty-setup-hook #'~/setup-C-m)
;; (add-hook 'window-setup-hook #'~/setup-C-m)
;; (add-hook 'terminal-init-xterm-hook #'~/setup-C-m)
;; (add-hook 'after-make-frame-functions #'~/setup-C-m)
;;
;; had to eval the code in each emacsclient invocation

(use-package selected
  :init (selected-global-mode))

(use-package multiple-cursors
  ;; - Sometimes you end up with cursors outside of your view. You can scroll
  ;;   the screen to center on each cursor with `C-v` and `M-v`.
  ;;
  ;; - If you get out of multiple-cursors-mode and yank - it will yank only
  ;;   from the kill-ring of main cursor. To yank from the kill-rings of every
  ;;   cursor use yank-rectangle, normally found at C-x r y.

  :bind (("C-'" . set-rectangular-region-anchor)

         ("<C-m> ^"     . mc/edit-beginnings-of-lines)
         ("<C-m> `"     . mc/edit-beginnings-of-lines)
         ("<C-m> $"     . mc/edit-ends-of-lines)
         ("<C-m> '"     . mc/edit-ends-of-lines)
         ("<C-m> R"     . mc/reverse-regions)
         ("<C-m> S"     . mc/sort-regions)
         ("<C-m> W"     . mc/mark-all-words-like-this)
         ("<C-m> Y"     . mc/mark-all-symbols-like-this)
         ("<C-m> a"     . mc/mark-all-like-this-dwim)
         ("<C-m> c"     . mc/mark-all-dwim)
         ("<C-m> l"     . mc/insert-letters)
         ("<C-m> n"     . mc/insert-numbers)
         ("<C-m> r"     . mc/mark-all-in-region-regexp)
         ("<C-m> t"     . mc/mark-sgml-tag-pair)
         ("<C-m> w"     . mc/mark-next-like-this-word)
         ("<C-m> x"     . mc/mark-more-like-this-extended)
         ("<C-m> y"     . mc/mark-next-like-this-symbol)
         ("<C-m> C-SPC" . mc/mark-pop)
         ("<C-m> ("     . mc/mark-all-symbols-like-this-in-defun)
         ("<C-m> C-("   . mc/mark-all-words-like-this-in-defun)
         ("<C-m> M-("   . mc/mark-all-like-this-in-defun)
         ("<C-m> ["     . mc/vertical-align-with-space)
         ("<C-m> {"     . mc/vertical-align))

  :bind (:map selected-keymap
              ("C-'" . mc/edit-lines)
              ("c"   . mc/edit-lines)
              ("."   . mc/mark-next-like-this)
              ("<"   . mc/unmark-next-like-this)
              ("C->" . mc/skip-to-next-like-this)
              (","   . mc/mark-previous-like-this)
              (">"   . mc/unmark-previous-like-this)
              ("C-<" . mc/skip-to-previous-like-this)
              ("y"   . mc/mark-next-symbol-like-this)
              ("Y"   . mc/mark-previous-symbol-like-this)
              ("w"   . mc/mark-next-word-like-this)
              ("W"   . mc/mark-previous-word-like-this)))

(use-package proof-site)

(use-package company-coq
  :init (add-hook 'coq-mode-hook #'company-coq-mode))


;; https://github.com/abo-abo/swiper/issues/776

(defun counsel-env-res (res path)
  (let ((apath (abbreviate-file-name path)))
    (list (car res)
          (if (file-accessible-directory-p path)
              (file-name-as-directory apath)
            apath))))

(defun counsel-env ()
  (delq nil
        (mapcar
         (lambda (s)
           (let* ((res (split-string s "=" t))
                  (path (cadr res)))
             (when (stringp path)
               (cond ((file-exists-p path)
                      (counsel-env-res res path))
                     ((file-exists-p (expand-file-name path ivy--directory))
                      (counsel-env-res
                       res (expand-file-name path ivy--directory)))
                     (t nil)))))
         process-environment)))

(defun counsel-expand-env ()
  (interactive)
  (if (equal ivy-text "")
      (progn
        (let ((enable-recursive-minibuffers t)
              (history (symbol-value (ivy-state-history ivy-last)))
              (old-last ivy-last)
              (ivy-recursive-restore nil))
          (ivy-read "Env: " (counsel-env)
                    :action (lambda (x)
                              (ivy--reset-state (setq ivy-last old-last))
                              (setq ivy--directory "")
                              (delete-minibuffer-contents)
                              (insert (cadr x))))))
    (insert "$")))
(eval-after-load 'counsel
      '(define-key counsel-find-file-map (kbd "$") 'counsel-expand-env))

;; (require 'haskell-interactive-mode)
;; (require 'haskell-process)
;; (add-hook 'haskell-mode-hook 'interactive-haskell-mode)
;; ;;; does not seem to work
;; (define-key haskell-interactive-mode-map (kbd "M-.") 'haskell-mode-goto-loc)
;; (define-key haskell-interactive-mode-map (kbd "C-c C-t") 'haskell-mode-show-type-at)

;;; https://scripter.co/converting-org-keywords-to-lower-case/
(defun modi/lower-case-org-keywords ()
  "Lower case Org keywords and block identifiers.

Example: \"#+TITLE\" -> \"#+title\"
         \"#+BEGIN_EXAMPLE\" -> \"#+begin_example\"

Inspiration:
https://code.orgmode.org/bzg/org-mode/commit/13424336a6f30c50952d291e7a82906c1210daf0."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((case-fold-search nil)
          (count 0))
      ;; Match examples: "#+FOO bar", "#+FOO:", "=#+FOO=", "~#+FOO~",
      ;;                 "‘#+FOO’", "“#+FOO”", ",#+FOO bar",
      ;;                 "#+FOO_bar<eol>", "#+FOO<eol>".
      (while (re-search-forward "\\(?1:#\\+[A-Z_]+\\(?:_[[:alpha:]]+\\)*\\)\\(?:[ :=~’”]\\|$\\)" nil :noerror)
        (setq count (1+ count))
        (replace-match (downcase (match-string-no-properties 1)) :fixedcase nil nil 1))
      (message "Lower-cased %d matches" count))))

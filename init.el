;;; init.el --- Personal configuration file -*- lexical-binding: t -*-

;; Copyright (c) 2021  Protesilaos Stavrou <info@protesilaos.com>

;; Author: Protesilaos Stavrou <info@protesilaos.com>
;; URL: https://protesilaos.com/emacs/beginner-emacs
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1"))

;; This file is NOT part of GNU Emacs.

;; This file is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the
;; Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;;
;; This file is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this file.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; NOTE 2021-12-25: This is experimental and far from finalised.  All I
;; have done is move some code from my dotemacs and tweak a few things.
;; There is no README yet, which will hopefully dissuade you from
;; proceeding.

;; This is the configuration file that provides a usable environment for
;; beginners to Emacs who have no interest to learn all the
;; idiosyncracies of Emacs but still want to benefit from some of its
;; advanced features.
;;
;; I am setting this up as I need a basis for non-tech-savvy people like
;; my neighbours.  While simplified, this setup is still based on my
;; dotemacs: <https://protesilaos.com/emacs/dotemacs>.  It is not
;; intended for general use as it is very opinionated and I will
;; continue to adjust it to my evolving needs.
;;
;; To stress the fact that THIS IS NOT FOR GENERAL USE, I am not setting
;; up `use-package' or MELPA.
;;
;; The namespace we are using here for custom code is `beeb' which is an
;; acronym for "BE for Emacs Beginners" or else "Beginners Enthused;
;; Experts Beguiled".
;;
;; This file's sections make it possible to navigate it with the help of
;; `M-x outline-minor-mode'.

;;; Code:

(require 'package)

;;;; Basic macros for package management

(defvar beeb-autoinstall-elpa nil
  "Whether `beeb-elpa-package' should install packages.
The default nil value means never to automatically install
packages.  A non-nil value is always interpreted as consent for
auto-installing everything---this process does not cover manually
maintained git repos, controlled by `beeb-manual-package'.")

;; This variable is incremented in beeb.org.  The idea is to
;; produce a list of packages that we want to install on demand from an
;; ELPA, when `beeb-autoinstall-elpa' is set to nil (the default).
;;
;; So someone who tries to reproduce my Emacs setup will first get a
;; bunch of warnings about unavailable packages, though not
;; show-stopping errors, and will then have to use the command
;; `beeb-install-ensured'.  After that command does its job, a
;; re-run of my Emacs configurations will yield the expected results.
;;
;; The assumption is that such a user will want to inspect the elements
;; of `beeb-ensure-install', remove from the setup whatever code
;; block they do not want, and then call the aforementioned command.
;;
;; I do not want to maintain a setup that auto-installs everything on
;; first boot without requiring explicit consent.  I think that is a bad
;; practice because it teaches the user to simply put their faith in the
;; provider.
(defvar beeb-ensure-install nil
  "List of package names used by `beeb-install-ensured'.")

(defun beeb-install-ensured ()
  "Install all `beeb-ensure-install' packages, if needed.
If a package is already installed, no further action is performed
on it."
  (interactive)
  (when (yes-or-no-p (format "Try to install %d packages?"
                             (length beeb-ensure-install)))
    (package-refresh-contents)
    (mapc (lambda (package)
            (unless (package-installed-p package)
              (package-install package)))
          beeb-ensure-install)))

(defmacro beeb-builtin-package (package &rest body)
  "Set up builtin PACKAGE with rest BODY.
PACKAGE is a quoted symbol, while BODY consists of balanced
expressions."
  (declare (indent 1))
  `(progn
     (unless (require ,package nil 'noerror)
       (display-warning 'beeb (format "Loading `%s' failed" ,package) :warning))
     ,@body))

(defmacro beeb-elpa-package (package &rest body)
  "Set up PACKAGE from an Elisp archive with rest BODY.
PACKAGE is a quoted symbol, while BODY consists of balanced
expressions.

When `beeb-autoinstall-elpa' is non-nil try to install the
package if it is missing."
  (declare (indent 1))
  `(progn
     (when (and beeb-autoinstall-elpa
                (not (package-installed-p ,package)))
       (package-install ,package))
     (if (require ,package nil 'noerror)
         (progn ,@body)
       (display-warning 'beeb (format "Loading `%s' failed" ,package) :warning)
       (add-to-list 'beeb-ensure-install ,package)
       (display-warning
        'beeb
        (format "Run `beeb-install-ensured' to install all packages in `beeb-ensure-install'")
        :warning))))

;;;; General settings

(setq frame-title-format '("%b"))
(setq default-input-method "greek")
(setq ring-bell-function 'ignore)

(setq use-short-answers t)    ; for Emacs28, replaces the defalias below
;; (defalias 'yes-or-no-p 'y-or-n-p)

(put 'overwrite-mode 'disabled t)

(setq initial-buffer-choice t)			; always start with *scratch*
(setq save-interprogram-paste-before-kill t)

(add-hook 'after-init-hook #'column-number-mode)

(setq-default fill-column 72)
(setq sentence-end-double-space t)
(setq sentence-end-without-period nil)
(setq colon-double-space nil)
(setq use-hard-newlines nil)
(setq adaptive-fill-mode t)

;; Disable some commands that will not help the users I have in mind and
;; map some useful commands to relevant keys.
(let ((map global-map))
  (define-key map (kbd "<insert>") nil)
  (define-key map (kbd "C-x C-z") nil)
  (define-key map (kbd "C-h h") nil)
  (define-key map (kbd "M-`") nil)
  (define-key map (kbd "M-SPC") #'cycle-spacing)
  (define-key map (kbd "M-c") #'capitalize-dwim)
  (define-key map (kbd "M-l") #'downcase-dwim)        ; "lower" case
  (define-key map (kbd "M-u") #'upcase-dwim)
  (define-key map (kbd "M-=") #'count-words))

;;;; Package configurations

;;;;; Familiar key bindings (cua-mode.el)

(beeb-builtin-package 'cua-base
  (cua-mode 1))

;;;;; Help for key binding sequences (which-key.el)

(beeb-elpa-package 'which-key
  (setq which-key-dont-use-unicode t)
  (setq which-key-add-column-padding 2)
  (setq which-key-show-early-on-C-h nil)
  (setq which-key-idle-delay 0.8)
  (setq which-key-idle-secondary-delay 0.05)
  (setq which-key-popup-type 'side-window)
  (setq which-key-show-prefix 'echo)
  (setq which-key-max-display-columns 3)
  (setq which-key-separator "  ")
  (setq which-key-special-keys nil)
  (setq which-key-paging-key "<next>")
  (which-key-mode 1))	   ; and turn this on, if you want to use this

;;;;; Custom UI

(beeb-builtin-package 'cus-edit
  (setq custom-file (make-temp-file "emacs-custom-")))

;;;;; Auto-revert

(beeb-builtin-package 'autorevert
  (setq auto-revert-verbose t)
  (add-hook 'after-init-hook #'global-auto-revert-mode))

;;;;; Modus themes (highly accessible and configurable themes)

(require-theme 'modus-themes) ; Only needed for the Emacs28+ built-in version

(beeb-builtin-package 'modus-themes
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts nil
        modus-themes-subtle-line-numbers t
        modus-themes-intense-markup nil
        modus-themes-deuteranopia nil
        modus-themes-tabs-accented nil
        modus-themes-variable-pitch-ui nil
        modus-themes-inhibit-reload t ; only applies to `customize-set-variable' and related

        modus-themes-fringes 'subtle ; {nil,'subtle,'intense}

        ;; Options for `modus-themes-lang-checkers' are either nil (the
        ;; default), or a list of properties that may include any of those
        ;; symbols: `straight-underline', `text-also', `background',
        ;; `intense' OR `faint'.
        modus-themes-lang-checkers '(text-also straight-underline)

        ;; Options for `modus-themes-mode-line' are either nil, or a list
        ;; that can combine any of `3d' OR `moody', `borderless',
        ;; `accented', and a natural number for extra padding
        modus-themes-mode-line '(accented 4)

        ;; Options for `modus-themes-syntax' are either nil (the default),
        ;; or a list of properties that may include any of those symbols:
        ;; `faint', `yellow-comments', `green-strings', `alt-syntax'
        modus-themes-syntax nil

        ;; Options for `modus-themes-hl-line' are either nil (the default),
        ;; or a list of properties that may include any of those symbols:
        ;; `accented', `underline', `intense'
        modus-themes-hl-line '(intense)

        ;; Options for `modus-themes-paren-match' are either nil (the
        ;; default), or a list of properties that may include any of those
        ;; symbols: `bold', `intense', `underline'
        modus-themes-paren-match '(intense bold)

        ;; Options for `modus-themes-links' are either nil (the default),
        ;; or a list of properties that may include any of those symbols:
        ;; `neutral-underline' OR `no-underline', `faint' OR `no-color',
        ;; `bold', `italic', `background'
        modus-themes-links '(neutral-underline)

        ;; Options for `modus-themes-prompts' are either nil (the
        ;; default), or a list of properties that may include any of those
        ;; symbols: `background', `bold', `gray', `intense', `italic'
        modus-themes-prompts nil

        modus-themes-completions 'moderate ; {nil,'moderate,'opinionated}

        modus-themes-mail-citations nil ; {nil,'faint,'monochrome}

        ;; Options for `modus-themes-region' are either nil (the default),
        ;; or a list of properties that may include any of those symbols:
        ;; `no-extend', `bg-only', `accented'
        modus-themes-region '(accented no-extend)

        ;; Options for `modus-themes-diffs': nil, 'desaturated, 'bg-only
        modus-themes-diffs nil

        modus-themes-org-blocks 'gray-background ; {nil,'gray-background,'tinted-background}

        modus-themes-org-agenda ; this is an alist: read the manual or its doc string
        '((header-block . (variable-pitch regular 1.4))
          (header-date . (bold-today grayscale underline-today 1.2))
          (event . (accented varied))
          (scheduled . uniform)
          (habit . traffic-light))

        modus-themes-headings ; this is an alist: read the manual or its doc string
        '((1 . (variable-pitch regular 1.4))
          (2 . (1.2))
          (t . (rainbow 1.05))))

  ;; Load the theme files before enabling a theme (else you get an error).
  (modus-themes-load-themes)

  ;; Custom faces (for demo purposes---check the themes' manual for more
  ;; advanced uses).
  (defun beeb-modus-themes-custom-faces ()
    (modus-themes-with-colors
      (custom-set-faces
       `(fill-column-indicator ((,class :background ,bg-inactive
                                        :foreground ,bg-inactive))))))

  (add-hook 'modus-themes-after-load-theme-hook #'beeb-modus-themes-custom-faces)

  (modus-themes-load-operandi) ;; OR modus-themes-load-vivendi

  (define-key global-map (kbd "<f5>") #'modus-themes-toggle))

;;;;; Handle performance for very long lines (so-long.el)

(beeb-builtin-package 'so-long
  (global-so-long-mode 1))

;;;;; Completion framework

;;;;;; Orderless completion style

(beeb-elpa-package 'orderless
  (setq orderless-component-separator " +")
  
  ;; SPC should never complete: use it for `orderless' groups.
  (let ((map minibuffer-local-completion-map))
    (define-key map (kbd "SPC") nil)
    (define-key map (kbd "?") nil)))

;;;;;; Completion annotations (marginalia)

(beeb-elpa-package 'marginalia
  (marginalia-mode 1))

;;;;;; Minibuffer configurations and Vertico

(beeb-builtin-package 'minibuffer
  ;; NOTE 2021-10-25: I am adding `basic' because it works better as a
  ;; default for some contexts.  Read:
  ;; <https://debbugs.gnu.org/cgi/bugreport.cgi?bug=50387>.
  (setq completion-styles
        '(basic substring initials flex partial-completion orderless))
  (setq completion-category-overrides
        '((file (styles . (basic partial-completion orderless)))))
  (setq completion-cycle-threshold 2)
  (setq completion-flex-nospace nil)
  (setq completion-pcm-complete-word-inserts-delimiters nil)
  (setq completion-pcm-word-delimiters "-_./:| ")
  (setq completion-ignore-case t)
  (setq completions-detailed t)
  (setq-default case-fold-search t)   ; For general regexp

  ;; Grouping of completions for Emacs 28
  (setq completions-group t)
  (setq completions-group-sort nil)
  (setq completions-group-format
        (concat
         (propertize "    " 'face 'completions-group-separator)
         (propertize " %s " 'face 'completions-group-title)
         (propertize " " 'face 'completions-group-separator
                     'display '(space :align-to right))))

  (setq read-buffer-completion-ignore-case t)
  (setq read-file-name-completion-ignore-case t)

  (setq enable-recursive-minibuffers t)
  (setq read-answer-short t) ; also check `use-short-answers' for Emacs28
  (setq resize-mini-windows t)
  (setq minibuffer-eldef-shorten-default t)

  (setq echo-keystrokes 0.25)           ; from the C source code

  ;; Do not allow the cursor to move inside the minibuffer prompt.  I
  ;; got this from the documentation of Daniel Mendler's Vertico
  ;; package: <https://github.com/minad/vertico>.
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))

  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  
  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  (setq read-extended-command-predicate #'command-completion-default-include-p)

  (file-name-shadow-mode 1)
  (minibuffer-depth-indicate-mode 1)
  (minibuffer-electric-default-mode 1)

  ;; I use this prefix for other searches
  (define-key minibuffer-local-must-match-map (kbd "M-s") nil))

(beeb-elpa-package 'vertico
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; Alternatively try `consult-completing-read-multiple'.
  (defun crm-indicator (args)
    (cons (concat "[CRM] " (car args)) (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  (setq vertico-count 20)
  (setq vertico-resize t)
  (setq vertico-cycle t)

  (vertico-mode 1))

;;;;;; Minibuffer history (savehist-mode)

(beeb-builtin-package 'savehist
  (setq savehist-file (locate-user-emacs-file "savehist"))
  (setq history-length 10000)
  (setq history-delete-duplicates t)
  (setq savehist-save-minibuffer-history t)
  (savehist-mode 1))

;;;;;; Enhanced minibuffer commands (consult.el)

(beeb-elpa-package 'consult
  (setq consult-line-numbers-widen t)
  ;; (setq completion-in-region-function #'consult-completion-in-region)
  (setq consult-async-min-input 3)
  (setq consult-async-input-debounce 0.5)
  (setq consult-async-input-throttle 0.8)
  (setq consult-narrow-key ">")

  (setq consult-preview-key 'any)

  (let ((map global-map))
    (define-key map [remap goto-line] #'consult-goto-line)
    (define-key map (kbd "M-K") #'consult-keep-lines) ; M-S-k is similar to M-S-5 (M-%)
    (define-key map (kbd "M-F") #'consult-focus-lines) ; same principle
    (define-key map (kbd "C-x b") #'consult-buffer)
    (define-key map (kbd "M-s M-s") #'consult-outline)
    (define-key map (kbd "M-s M-l") #'consult-line)
    (define-key map (kbd "M-s M-i") #'consult-imenu)
    (define-key map (kbd "M-s M-f") #'consult-find)
    (define-key map (kbd "M-s M-g") #'consult-grep))
  (define-key consult-narrow-map (kbd "?") #'consult-narrow-help))

;;;;;; Completion for recent files and directories

(beeb-builtin-package 'recentf
  (setq recentf-save-file (locate-user-emacs-file "recentf"))
  (setq recentf-max-saved-items 200)
  (setq recentf-exclude '(".gz" ".xz" ".zip" "/elpa/" "/ssh:" "/sudo:"))
  (recentf-mode 1))

;;;;;; Extended minibuffer actions and more (embark.el)

(beeb-elpa-package 'embark
  (setq prefix-help-command #'embark-prefix-help-command)
  ;; (setq prefix-help-command #'describe-prefix-bindings) ; the default of the above
  (setq embark-collect-initial-view-alist '((t . list)))
  (setq embark-quit-after-action t)     ; XXX: Read the doc string!
  (setq embark-collect-live-update-delay 0.5)
  (setq embark-collect-live-initial-delay 0.8)
  (setq embark-verbose-indicator-excluded-actions
        '("\\`embark-collect-" "\\`customize-" "\\(local\\|global\\)-set-key"
          set-variable embark-cycle embark-export
          embark-keymap-help embark-become embark-isearch))
  (setq embark-verbose-indicator-buffer-sections
        `(target "\n" shadowed-targets " " cycle "\n" bindings))
  (setq embark-mixed-indicator-both nil)
  (setq embark-mixed-indicator-delay 1.2)
  ;;  NOTE 2021-07-28: This is used when `embark-indicator' is set to
  ;;  `embark-mixed-indicator' or `embark-verbose-indicator'.  We can
  ;;  specify the window parameters here, but I prefer to do that in my
  ;;  `display-buffer-alist' (search this document) because it is easier
  ;;  to keep track of all my rules in one place.
  (setq embark-verbose-indicator-display-action nil)

  (define-key global-map (kbd "C-.") #'embark-act)
  (let ((map minibuffer-local-completion-map))
    (define-key map (kbd "C-.") #'embark-act)
    (define-key map (kbd "C->") #'embark-become)
    (define-key map (kbd "M-q") #'embark-collect-toggle-view)) ; parallel of `fill-paragraph'
  (let ((map embark-collect-mode-map))
    (define-key map (kbd "C-,") #'embark-act)
    (define-key map (kbd "M-q") #'embark-collect-toggle-view))
  (let ((map embark-region-map))
    (define-key map (kbd "a") #'align-regexp)
    (define-key map (kbd "i") #'epa-import-keys-region)
    (define-key map (kbd "r") #'repunctuate-sentences) ; overrides `rot13-region'
    (define-key map (kbd "s") #'sort-lines)
    (define-key map (kbd "u") #'untabify))
  (let ((map embark-symbol-map))
    (define-key map (kbd ".") #'embark-find-definition)
    (define-key map (kbd "k") #'describe-keymap)))

;; Needed for correct exporting while using Embark with Consult
;; commands.
(beeb-elpa-package 'embark-consult)

;;;;; Search methods

;;;;;; Isearch (buffer-wide interactive search)

(beeb-builtin-package 'isearch
  (setq search-highlight t)
  (setq search-whitespace-regexp ".*?")
  (setq isearch-lax-whitespace t)
  (setq isearch-regexp-lax-whitespace nil)
  (setq isearch-lazy-highlight t)
  ;; All of the following variables were introduced in Emacs 27.1.
  (setq isearch-lazy-count t)
  (setq lazy-count-prefix-format nil)
  (setq lazy-count-suffix-format " (%s/%s)")
  (setq isearch-yank-on-move 'shift)
  (setq isearch-allow-scroll 'unlimited)
  ;; These variables are from Emacs 28
  (setq isearch-repeat-on-direction-change t)
  (setq lazy-highlight-initial-delay 0.5)
  (setq lazy-highlight-no-delay-length 3)
  (setq isearch-wrap-pause t)

  (define-key minibuffer-local-isearch-map (kbd "M-/") #'isearch-complete-edit)
  (let ((map isearch-mode-map))
    (define-key map (kbd "C-g") #'isearch-cancel) ; instead of `isearch-abort'
    (define-key map (kbd "M-/") #'isearch-complete)))

(beeb-builtin-package 'replace
  (setq list-matching-lines-jump-to-current-line t)
  (add-hook 'occur-mode-hook #'hl-line-mode)
  (define-key occur-mode-map (kbd "t") #'toggle-truncate-lines))

;;;;;; wgrep (writable grep)

(beeb-elpa-package 'wgrep
  (setq wgrep-auto-save-buffer t)
  (setq wgrep-change-readonly-file t)
  (let ((map grep-mode-map))
    (define-key map (kbd "e") #'wgrep-change-to-wgrep-mode)
    (define-key map (kbd "C-x C-q") #'wgrep-change-to-wgrep-mode)
    (define-key map (kbd "C-c C-c") #'wgrep-finish-edit)))

;;;;; File management

;;;;;; Dired (directory editor) and extras

(beeb-builtin-package 'dired
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'always)
  (setq delete-by-moving-to-trash t)
  (setq dired-listing-switches
        "-AGFhlv --group-directories-first --time-style=long-iso")
  (setq dired-dwim-target t)
  (setq dired-auto-revert-buffer #'dired-directory-changed-p) ; also see `dired-do-revert-buffer'
  (setq dired-make-directory-clickable t) ; Emacs 29.1
  (setq dired-free-space nil) ; Emacs 29.1

  (add-hook 'dired-mode-hook #'dired-hide-details-mode)
  (add-hook 'dired-mode-hook #'hl-line-mode))

(beeb-builtin-package 'dired-aux
  (setq dired-isearch-filenames 'dwim)
  ;; The following variables were introduced in Emacs 27.1
  (setq dired-create-destination-dirs 'ask)
  (setq dired-vc-rename-file t)
  ;; And this is for Emacs 28
  (setq dired-do-revert-buffer (lambda (dir) (not (file-remote-p dir))))

  (let ((map dired-mode-map))
    (define-key map (kbd "C-+") #'dired-create-empty-file)
    (define-key map (kbd "M-s f") #'nil)
    (define-key map (kbd "C-x v v") #'dired-vc-next-action))) ; Emacs 28

(beeb-builtin-package 'dired-x
  (setq dired-clean-up-buffers-too t)
  (setq dired-clean-confirm-killing-deleted-buffers t)
  (setq dired-x-hands-off-my-keys t)    ; easier to show the keys I use
  (setq dired-bind-man nil)
  (setq dired-bind-info nil)
  (define-key dired-mode-map (kbd "I") #'dired-info))

(beeb-elpa-package 'dired-subtree
  (setq dired-subtree-use-backgrounds nil)
  (let ((map dired-mode-map))
    (define-key map (kbd "<tab>") #'dired-subtree-toggle)
    (define-key map (kbd "<backtab>") #'dired-subtree-remove))) ; S-TAB

(beeb-builtin-package 'wdired
  (setq wdired-allow-to-change-permissions t)
  (setq wdired-create-parent-directories t))

(beeb-builtin-package 'image-dired
  (setq image-dired-external-viewer "xdg-open")
  (setq image-dired-thumb-size 80)
  (setq image-dired-thumb-margin 2)
  (setq image-dired-thumb-relief 0)
  (setq image-dired-thumbs-per-row 4)
  (define-key image-dired-thumbnail-mode-map
    (kbd "<return>") #'image-dired-thumbnail-display-external))

;;;;;; dired-like mode for the trash (trashed.el)

(beeb-elpa-package 'trashed
  (setq trashed-action-confirmer 'y-or-n-p)
  (setq trashed-use-header-line t)
  (setq trashed-sort-key '("Date deleted" . t))
  (setq trashed-date-format "%Y-%m-%d %H:%M:%S"))

;;;;; Buffer and window management

;;;;;; Unique names for buffers

(beeb-builtin-package 'uniquify
  (setq uniquify-buffer-name-style 'forward)
  (setq uniquify-strip-common-suffix t)
  (setq uniquify-after-kill-buffer-p t))

;;;;;; Ibuffer and extras (dired-like buffer list manager)

(beeb-builtin-package 'ibuffer
  (setq ibuffer-expert t)
  (setq ibuffer-display-summary nil)
  (setq ibuffer-use-other-window nil)
  (setq ibuffer-show-empty-filter-groups nil)
  (setq ibuffer-movement-cycle nil)
  (setq ibuffer-default-sorting-mode 'filename/process)
  (setq ibuffer-use-header-line t)
  (setq ibuffer-default-shrink-to-minimum-size nil)
  (setq ibuffer-formats
        '((mark modified read-only locked " "
                (name 40 40 :left :elide)
                " "
                (size 9 -1 :right)
                " "
                (mode 16 16 :left :elide)
                " " filename-and-process)
          (mark " "
                (name 16 -1)
                " " filename)))
  (setq ibuffer-saved-filter-groups nil)
  (setq ibuffer-old-time 48)
  (add-hook 'ibuffer-mode-hook #'hl-line-mode)
  (define-key global-map (kbd "C-x C-b") #'ibuffer)
  (let ((map ibuffer-mode-map))
    (define-key map (kbd "* f") #'ibuffer-mark-by-file-name-regexp)
    (define-key map (kbd "* g") #'ibuffer-mark-by-content-regexp) ; "g" is for "grep"
    (define-key map (kbd "* n") #'ibuffer-mark-by-name-regexp)
    (define-key map (kbd "s n") #'ibuffer-do-sort-by-alphabetic)  ; "sort name" mnemonic
    (define-key map (kbd "/ g") #'ibuffer-filter-by-content)))

;;;;;; Window rules and basic tweaks (window.el)

(beeb-builtin-package 'window
  (setq display-buffer-alist
        `(;; bottom side window
          ("\\*Org Select\\*"
           (display-buffer-in-side-window)
           (dedicated . t)
           (side . bottom)
           (slot . 0)
           (window-parameters . ((mode-line-format . none))))
          ;; bottom buffer (NOT side window)
          ("\\*Embark Actions\\*"
           (display-buffer-reuse-mode-window display-buffer-at-bottom)
           (window-height . fit-window-to-buffer)
           (window-parameters . ((no-other-window . t)
                                 (mode-line-format . none))))
          ("\\*\\(Output\\|Register Preview\\).*"
           (display-buffer-reuse-mode-window display-buffer-at-bottom))
          ;; below current window
          ("\\*.*\\(e?shell\\|v?term\\).*"
           (display-buffer-reuse-mode-window display-buffer-below-selected))
          ("\\*\\vc-\\(incoming\\|outgoing\\|git : \\).*"
           (display-buffer-reuse-mode-window display-buffer-below-selected)
           ;; NOTE 2021-10-06: we cannot `fit-window-to-buffer' because
           ;; the height is not known in advance.
           (window-height . 0.2))
          ("\\*\\(Calendar\\|Bookmark Annotation\\).*"
           (display-buffer-reuse-mode-window display-buffer-below-selected)
           (window-height . fit-window-to-buffer))))

  (setq window-combination-resize t)
  (setq even-window-sizes 'height-only)
  (setq window-sides-vertical nil)
  (setq switch-to-buffer-in-dedicated-window 'pop)

  (let ((map global-map))
    (define-key map (kbd "C-x C-n") #'next-buffer)     ; override `set-goal-column'
    (define-key map (kbd "C-x C-p") #'previous-buffer) ; override `mark-page'
    (define-key map (kbd "C-x <down>") #'next-buffer)
    (define-key map (kbd "C-x <up>") #'previous-buffer)))

;;;;;; Window history (winner-mode)

(beeb-builtin-package 'winner
  (winner-mode 1)
  (let ((map global-map))
    (define-key map (kbd "C-x <right>") #'winner-redo)
    (define-key map (kbd "C-x <left>") #'winner-undo)))

;;;;;; Directional window motions (windmove)

(beeb-builtin-package 'windmove
  (setq windmove-create-window nil)     ; Emacs 27.1
  (let ((map global-map))
    ;; Those override some commands that are already available with
    ;; C-M-u, C-M-f, C-M-b.  No need to bind the arrow keys as well.
    (define-key map (kbd "C-M-<up>") #'windmove-up)
    (define-key map (kbd "C-M-<right>") #'windmove-right)
    (define-key map (kbd "C-M-<down>") #'windmove-down)
    (define-key map (kbd "C-M-<left>") #'windmove-left)
    (define-key map (kbd "C-M-S-<up>") #'windmove-swap-states-up)
    (define-key map (kbd "C-M-S-<right>") #'windmove-swap-states-right) ; conflicts with `org-increase-number-at-point'
    (define-key map (kbd "C-M-S-<down>") #'windmove-swap-states-down)
    (define-key map (kbd "C-M-S-<left>") #'windmove-swap-states-left)))

;;;;; Focus mode

(beeb-elpa-package 'olivetti
  (setq-default olivetti-body-width 0.7)
  (setq-default olivetti-minimum-body-width 80)
  (setq-default olivetti-recall-visual-line-mode-entry-state t)
  (define-key global-map (kbd "<f6>") #'olivetti-mode))

;;;;; Personal Information Management

;;;;;; Org mode

(beeb-builtin-package 'org
  (setq org-directory (convert-standard-filename "~/Documents/org"))
  (setq org-imenu-depth 7)
;;;;;;; general settings
  (setq org-adapt-indentation nil)      ; No, non, nein, όχι!
  (setq org-special-ctrl-a/e nil)
  (setq org-special-ctrl-k nil)
  (setq org-M-RET-may-split-line '((default . nil)))
  (setq org-hide-emphasis-markers t)
  (setq org-hide-macro-markers t)
  (setq org-hide-leading-stars nil)
  (setq org-cycle-separator-lines 0)
  (setq org-structure-template-alist    ; CHANGED in Org 9.3, Emacs 27.1
        '(("s" . "src")
          ("E" . "src emacs-lisp")
          ("e" . "example")
          ("q" . "quote")
          ("v" . "verse")
          ("V" . "verbatim")
          ("c" . "center")
          ("C" . "comment")))
  (setq org-catch-invisible-edits 'show)
  (setq org-return-follows-link nil)
  (setq org-loop-over-headlines-in-active-region 'start-level)
  (setq org-modules '(ol-info ol-eww))
  (setq org-use-sub-superscripts '{})
  (setq org-insert-heading-respect-content t)

;;;;;;; refile, todo
  (setq org-refile-targets
        '((org-agenda-files . (:maxlevel . 2))
          (nil . (:maxlevel . 2))))
  (setq org-refile-use-outline-path t)
  (setq org-refile-allow-creating-parent-nodes 'confirm)
  (setq org-refile-use-cache t)
  (setq org-reverse-note-order nil)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "MAYBE(m)" "WAIT(w@/!)" "|" "CANCEL(c@)" "DONE(d!)")))
  (setq org-todo-keyword-faces
        '(("WAIT" . '(bold org-todo))
          ("MAYBE" . '(bold shadow))
          ("CANCEL" . '(bold org-done))))
  (setq org-use-fast-todo-selection 'expert)
  (setq org-priority-faces
        '((?A . '(bold org-priority))
          (?B . org-priority)
          (?C . '(shadow org-priority))))
  (setq org-fontify-done-headline nil)
  (setq org-fontify-quote-and-verse-blocks t)
  (setq org-fontify-whole-heading-line nil)
  (setq org-fontify-whole-block-delimiter-line nil)
  (setq org-highlight-latex-and-related nil) ; other options affect elisp regexp in src blocks
  (setq org-enforce-todo-dependencies t)
  (setq org-enforce-todo-checkbox-dependencies t)
  (setq org-track-ordered-property-with-tag t)
  (setq org-highest-priority ?A)
  (setq org-lowest-priority ?C)
  (setq org-default-priority ?A)

;;;;;;; tags
  (setq org-tag-alist ; I don't really use those, but whatever
        '(("meeting")
          ("admin")
          ("emacs")
          ("modus")
          ("politics")
          ("economics")
          ("philosophy")
          ("book")
          ("essay")
          ("mail")
          ("purchase")
          ("hardware")
          ("software")
          ("website")))

;;;;;;; log
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-log-note-clock-out nil)
  (setq org-log-redeadline 'time)
  (setq org-log-reschedule 'time)
  (setq org-read-date-prefer-future 'time)

;;;;;;; links
  (setq org-link-keep-stored-after-insertion nil)
  ;; TODO 2021-10-15 org-link-make-description-function

;;;;;;; capture
  (setq org-capture-templates
        `(("b" "Basic task for future review" entry
           (file+headline "tasks.org" "Tasks to be reviewed")
           ,(concat "* %^{Title}\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n\n"
                    "%i%l")
           :empty-lines-after 1)
          ("m" "Memorandum of conversation" entry
           (file+headline "tasks.org" "Tasks to be reviewed")
           ,(concat "* Memorandum of conversation with %^{Person}\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n\n"
                    "%i%?")
           :empty-lines-after 1)
          ("t" "Task with a due date" entry
           (file+headline "tasks.org" "Tasks with a date")
           ,(concat "* TODO %^{Title} %^g\n"
                    "SCHEDULED: %^t\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n\n"
                    "%i%?")
           :empty-lines-after 1)))

;;;;;;; agenda
;;;;;;;; Basic agenda setup
  (setq org-default-notes-file (thread-last org-directory (expand-file-name "notes.org")))
  (setq org-agenda-files `(,org-directory "~/Documents"))
  (setq org-agenda-span 'week)
  (setq org-agenda-start-on-weekday 1)  ; Monday
  (setq org-agenda-confirm-kill t)
  (setq org-agenda-show-all-dates t)
  (setq org-agenda-show-outline-path nil)
  (setq org-agenda-window-setup 'current-window)
  (setq org-agenda-skip-comment-trees t)
  (setq org-agenda-menu-show-matcher t)
  (setq org-agenda-menu-two-columns nil)
  (setq org-agenda-sticky nil)
  (setq org-agenda-custom-commands-contexts nil)
  (setq org-agenda-max-entries nil)
  (setq org-agenda-max-todos nil)
  (setq org-agenda-max-tags nil)
  (setq org-agenda-max-effort nil)

  ;; TODO 2021-12-25: This needs more work in my dotemacs as well.  A
  ;; polished solution will be included herein.
  ;;
  ;; ;; NOTE 2021-12-07: In my `prot-org.el' (see further below), I add
  ;; ;; `org-agenda-to-appt' to various relevant hooks.
  ;; ;;
  ;; ;; Create reminders for tasks with a due date when this file is read.
  ;; (run-at-time (* 60 5) nil #'org-agenda-to-appt)

;;;;;;;; General agenda view options
  ;; NOTE 2021-12-07: Check further below my `org-agenda-custom-commands'
  (setq org-agenda-prefix-format
        '((agenda . " %i %-12:c%?-12t% s")
          (todo . " %i %-12:c")
          (tags . " %i %-12:c")
          (search . " %i %-12:c")))
  (setq org-agenda-sorting-strategy
        '(((agenda habit-down time-up priority-down category-keep)
           (todo priority-down category-keep)
           (tags priority-down category-keep)
           (search category-keep))))
  (setq org-agenda-breadcrumbs-separator "->")
  (setq org-agenda-todo-keyword-format "%-1s")
  (setq org-agenda-fontify-priorities 'cookies)
  (setq org-agenda-category-icon-alist nil)
  (setq org-agenda-remove-times-when-in-prefix nil)
  (setq org-agenda-remove-timeranges-from-blocks nil)
  (setq org-agenda-compact-blocks nil)
  (setq org-agenda-block-separator ?—)

;;;;;;;; Agenda marks
  (setq org-agenda-bulk-mark-char "#")
  (setq org-agenda-persistent-marks nil)

;;;;;;;; Agenda diary entries
  (setq org-agenda-insert-diary-strategy 'date-tree)
  (setq org-agenda-insert-diary-extract-time nil)
  (setq org-agenda-include-diary nil)

;;;;;;;; Agenda follow mode
  (setq org-agenda-start-with-follow-mode nil)
  (setq org-agenda-follow-indirect t)

;;;;;;;; Agenda multi-item tasks
  (setq org-agenda-dim-blocked-tasks t)
  (setq org-agenda-todo-list-sublevels t)

;;;;;;;; Agenda filters and restricted views
  (setq org-agenda-persistent-filter nil)
  (setq org-agenda-restriction-lock-highlight-subtree t)

;;;;;;;; Agenda items with deadline and scheduled timestamps
  (setq org-agenda-include-deadlines t)
  (setq org-deadline-warning-days 5)
  (setq org-agenda-skip-scheduled-if-done nil)
  (setq org-agenda-skip-scheduled-if-deadline-is-shown t)
  (setq org-agenda-skip-timestamp-if-deadline-is-shown t)
  (setq org-agenda-skip-deadline-if-done nil)
  (setq org-agenda-skip-deadline-prewarning-if-scheduled 1)
  (setq org-agenda-skip-scheduled-delay-if-deadline nil)
  (setq org-agenda-skip-additional-timestamps-same-entry nil)
  (setq org-agenda-skip-timestamp-if-done nil)
  (setq org-agenda-search-headline-for-time nil)
  (setq org-scheduled-past-days 365)
  (setq org-deadline-past-days 365)
  (setq org-agenda-move-date-from-past-immediately-to-today t)
  (setq org-agenda-show-future-repeats t)
  (setq org-agenda-prefer-last-repeat nil)
  (setq org-agenda-timerange-leaders
        '("" "(%d/%d): "))
  (setq org-agenda-scheduled-leaders
        '("Scheduled: " "Sched.%2dx: "))
  (setq org-agenda-inactive-leader "[")
  (setq org-agenda-deadline-leaders
        '("Deadline:  " "In %3d d.: " "%2d d. ago: "))
  ;; Time grid
  (setq org-agenda-time-leading-zero t)
  (setq org-agenda-timegrid-use-ampm nil)
  (setq org-agenda-use-time-grid t)
  (setq org-agenda-show-current-time-in-grid t)
  (setq org-agenda-current-time-string
        (concat "Now " (make-string 70 ?-)))
  (setq org-agenda-time-grid
        '((daily today require-timed)
          (0600 0700 0800 0900 1000 1100
                1200 1300 1400 1500 1600
                1700 1800 1900 2000 2100)
          " ....." "-----------------"))
  (setq org-agenda-default-appointment-duration nil)

;;;;;;;; Agenda global to-do list
  (setq org-agenda-todo-ignore-with-date t)
  (setq org-agenda-todo-ignore-timestamp t)
  (setq org-agenda-todo-ignore-scheduled t)
  (setq org-agenda-todo-ignore-deadlines t)
  (setq org-agenda-todo-ignore-time-comparison-use-seconds t)
  (setq org-agenda-tags-todo-honor-ignore-options nil)

;;;;;;;; Agenda tagged items
  (setq org-agenda-show-inherited-tags t)
  (setq org-agenda-use-tag-inheritance
        '(todo search agenda))
  (setq org-agenda-hide-tags-regexp nil)
  (setq org-agenda-remove-tags nil)
  (setq org-agenda-tags-column -100)

;;;;;;;; Agenda entry
  ;; NOTE: I do not use this right now.  Leaving everything to its
  ;; default value.
  (setq org-agenda-start-with-entry-text-mode nil)
  (setq org-agenda-entry-text-maxlines 5)
  (setq org-agenda-entry-text-exclude-regexps nil)
  (setq org-agenda-entry-text-leaders "    > ")

;;;;;;;; Agenda logging and clocking
  ;; NOTE: I do not use these yet, though I plan to.  Leaving everything
  ;; to its default value for the time being.
  (setq org-agenda-log-mode-items '(closed clock))
  (setq org-agenda-clock-consistency-checks
        '((:max-duration "10:00" :min-duration 0 :max-gap "0:05" :gap-ok-around
                         ("4:00")
                         :default-face ; This should definitely be reviewed
                         ((:background "DarkRed")
                          (:foreground "white"))
                         :overlap-face nil :gap-face nil :no-end-time-face nil
                         :long-face nil :short-face nil)))
  (setq org-agenda-log-mode-add-notes t)
  (setq org-agenda-start-with-log-mode nil)
  (setq org-agenda-start-with-clockreport-mode nil)
  (setq org-agenda-clockreport-parameter-plist '(:link t :maxlevel 2))
  (setq org-agenda-search-view-always-boolean nil)
  (setq org-agenda-search-view-force-full-words nil)
  (setq org-agenda-search-view-max-outline-level 0)
  (setq org-agenda-search-headline-for-time t)
  (setq org-agenda-use-time-grid t)
  (setq org-agenda-cmp-user-defined nil)
  (setq org-agenda-sort-notime-is-late t) ; Org 9.4
  (setq org-agenda-sort-noeffort-is-high t) ; Org 9.4

;;;;;;;; Agenda column view
  ;; NOTE I do not use these, but may need them in the future.
  (setq org-agenda-view-columns-initially nil)
  (setq org-agenda-columns-show-summaries t)
  (setq org-agenda-columns-compute-summary-properties t)
  (setq org-agenda-columns-add-appointments-to-effort-sum nil)
  (setq org-agenda-auto-exclude-function nil)
  (setq org-agenda-bulk-custom-functions nil)

;;;;;;; code blocks
  (setq org-confirm-babel-evaluate nil)
  (setq org-src-window-setup 'current-window)
  (setq org-edit-src-persistent-message nil)
  (setq org-src-fontify-natively t)
  (setq org-src-preserve-indentation t)
  (setq org-src-tab-acts-natively t)
  (setq org-edit-src-content-indentation 0)

;;;;;;; export
  (setq org-export-with-toc t)
  (setq org-export-headline-levels 8)
  (setq org-export-dispatch-use-expert-ui nil)
  (setq org-html-htmlize-output-type nil)
  (setq org-html-head-include-default-style nil)
  (setq org-html-head-include-scripts nil)
  (require 'ox-texinfo)
  (require 'ox-md)
  ;; FIXME: how to remove everything else?
  (setq org-export-backends '(html texinfo md))

;;;;;;; IDs
  (setq org-id-link-to-org-use-id
        'create-if-interactive-and-no-custom-id)

;;;;;;; Key bindings
  (let ((map global-map))
    (define-key map (kbd "C-c a") #'org-agenda)
    (define-key map (kbd "C-c c") #'org-capture)
    (define-key map (kbd "C-c l") #'org-store-link))
  (let ((map org-mode-map))
    (define-key map (kbd "C-c S-l") #'org-toggle-link-display)
    (define-key map (kbd "C-c C-S-l") #'org-insert-last-stored-link)))

;;;;;; Calendar

(beeb-builtin-package 'calendar
  (setq calendar-mark-diary-entries-flag t)
  (setq calendar-mark-holidays-flag t)
  (setq calendar-mode-line-format nil)
  (setq calendar-time-display-form
        '(24-hours ":" minutes
                   (when time-zone
                     (format "(%s)" time-zone))))
  (setq calendar-week-start-day 1)      ; Monday
  (setq calendar-date-style 'iso)
  (setq calendar-date-display-form calendar-iso-date-display-form)
  (setq calendar-time-zone-style 'numeric) ; Emacs 28.1

  (require 'solar)
  (setq calendar-latitude 35.17         ; Not my actual coordinates
        calendar-longitude 33.36)

  (require 'cal-dst)
  (setq calendar-standard-time-zone-name "+0200")
  (setq calendar-daylight-time-zone-name "+0300"))

;;;;;; Appointment notifications

(beeb-builtin-package 'appt
  (setq appt-display-diary nil)
  (setq appt-disp-window-function #'appt-disp-window)
  (setq appt-display-mode-line t)
  (setq appt-display-interval 3)
  (setq appt-audible nil)
  (setq appt-warning-time-regexp "appt \\([0-9]+\\)")
  (setq appt-message-warning-time 6)

  (run-at-time 10 nil #'appt-activate 1))

;;;;; Mouse and general usability settings

;;;;;; Mouse wheel behaviour

(beeb-builtin-package 'mouse
  ;; In Emacs 27+, use Control + mouse wheel to scale text.
  (setq mouse-wheel-scroll-amount
        '(1
          ((shift) . 5)
          ((meta) . 0.5)
          ((control) . text-scale)))
  (setq mouse-drag-copy-region nil)
  (setq make-pointer-invisible t)
  (setq mouse-wheel-progressive-speed t)
  (setq mouse-wheel-follow-mouse t)
  (mouse-wheel-mode 1)
  (define-key global-map (kbd "C-M-<mouse-3>") #'tear-off-window))

;;;;;; Scrolling behaviour

(setq-default scroll-preserve-screen-position t)
(setq-default scroll-conservatively 1) ; affects `scroll-step'
(setq-default scroll-margin 0)
(setq-default next-screen-context-lines 0)

;;;;;; Delete selection

(beeb-builtin-package 'delsel
  (delete-selection-mode 1))

;;;;;; Tooltips (tooltip-mode)

(beeb-builtin-package 'tooltip
  (setq tooltip-delay 0.5)
  (setq tooltip-short-delay 0.5)
  (setq x-gtk-use-system-tooltips nil)
  (setq tooltip-frame-parameters
        '((name . "tooltip")
          (internal-border-width . 6)
          (border-width . 0)
          (no-special-glyphs . t)))
  (tooltip-mode 1))

;;;;;; Record cursor position

(beeb-builtin-package 'saveplace
  (setq save-place-file (locate-user-emacs-file "saveplace"))
  (setq save-place-forget-unreadable-files t)
  (save-place-mode 1))

;;;;;; Backups

(setq backup-directory-alist
      `(("." . ,(concat user-emacs-directory "backup/"))))
(setq backup-by-copying t)
(setq version-control t)
(setq delete-old-versions t)
(setq kept-new-versions 6)
(setq kept-old-versions 2)
(setq create-lockfiles nil)

;;;;;; Highlight matching parentheses (show-paren-mode)

(beeb-builtin-package 'paren
  (setq show-paren-style 'parenthesis)
  (setq show-paren-when-point-in-periphery nil)
  (setq show-paren-when-point-inside-paren nil)
  (show-paren-mode 1))

;; TODO 2021-12-25: Spelling

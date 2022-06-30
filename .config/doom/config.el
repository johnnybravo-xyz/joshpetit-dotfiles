;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/sync/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;
;; ## Stuff I ADDED!

(defun async-shell-command-to-string (command callback)
  "Execute shell command COMMAND asynchronously in the
  background.

Return the temporary output buffer which command is writing to
during execution.

When the command is finished, call CALLBACK with the resulting
output as a string."
  (let
      ((output-buffer (generate-new-buffer " *temp*"))
       (callback-fun callback))
    (set-process-sentinel
     (start-process "Shell" output-buffer shell-file-name shell-command-switch command)
     (lambda (process signal)
       (when (memq (process-status process) '(exit signal))
         (with-current-buffer output-buffer
           (let ((output-string
                  (buffer-substring-no-properties
                   (point-min)
                   (point-max))))
             (funcall callback-fun (string-trim output-string))))
         (kill-buffer output-buffer))))
    output-buffer))

(after! core-ui (menu-bar-mode 1))
(after! org

(setq org-capture-templates
      '(("m" "MS5" entry (file+headline "~/sync/org/programming/ms5.org" "MS5 Timesheet")
         "** Working on Ms5 %<%Y-%m-%d>\nSCHEDULED: %t"
         :clock-in t
         :clock-keep t
         :jump-to-captured t
         )
        ("n" "Note" entry (file "~/sync/org/refile.org")
         "* %?")
        ("w" "Work" entry (file+headline "~/sync/org/work.org" "Work logs")
         "** Work Log %t %?"
         :clock-in t
         :clock-keep t
         :jump-to-captured t
         )))



(org-link-set-parameters "asset" :follow #'org-blog-asset-follow :export #'org-blog-asset-export)

(defun org-blog-asset-follow (path)
  (org-open-file
   (format "./%s" path)))

(defun org-blog-asset-export (link description format _)
  "Export a man page link from Org files."
  "TODO: change to joshministers.com"
  "Docs here https://orgmode.org/manual/Adding-Hyperlink-Types.html"
  (let ((url (format "http://joshministers.com/static/%s" link))
        (desc (or description link)))
    (pcase format
      (`html (format "<a target=\"_blank\" href=\"%s\">%s</a>" url desc))
      (`latex (format "\\href{%s}{%s}" url desc))
      (`texinfo (format "@uref{%s,%s}" url desc))
      (`ascii (format "%s (%s)" desc url))
      (`md (format "[%s](/static/%s)" desc link))
      (_ path))))

(org-link-set-parameters "img-asset" :follow #'org-blog-asset-follow :export #'org-blog-img-asset-export)


(defun org-blog-img-asset-export (link description format _)
  (let ((url (format "http://man.he.net/?topic=%s&section=all" link))
        (desc (or description link)))
    (pcase format
      (`html (format "<img src=\"/static/%s\" alt=\"%s\">" link desc))
      (`latex (format "\includegraphics[width=.9\linewidth]{%s}" link desc))
      (`texinfo (format "@uref{%s,%s}" url desc))
      (`ascii (format "%s (%s)" desc url))
      (`md (format "![%s](/static/%s)" desc link))
      (_ path))))

(org-link-set-parameters "post" :follow #'org-blog-post-follow :export #'org-blog-post-export)

(defun org-blog-post-follow (path)
  (org-open-file
   (format "./%s" path)))


(defun org-blog-post-export (link description format _)
  (let ((url (format "/blog/%s" link))
        (desc (or description link)))
    (pcase format
      (`html (format "<a target=\"_blank\" href=\"%s\">%s</a>" url desc))
      (`latex (format "\\href{%s}{%s}" url desc))
      (`texinfo (format "@uref{%s,%s}" url desc))
      (`ascii (format "%s (%s)" desc url))
      (`md (format "[%s](/static/%s)" desc link))
      (_ path))))

(org-link-set-parameters "bible" :follow #'org-bible-follow :export #'org-bible-export)


(defun org-bible-follow (passage)
  (let* ((cooler-passage (replace-regexp-in-string "^\\(.+[0-9]\\)\\s-\\(.*\\)" "\\1,\\2" passage))
         (split-passage (split-string cooler-passage ","))
         (bible-version (or (nth 1 split-passage) "NASB"))
         (reference-normal (nth 0 split-passage))
         (choices '(("open in browser" . "goto-bible-reference") ("copy scripture" . "copy-scripture")))
         (reference (replace-regexp-in-string " " "\+" (nth 0 split-passage)))
         (url "https://www.biblegateway.com/bible?language=en&version=%s&passage=%s")
         (choice (alist-get (completing-read "Choose: " choices) choices nil nil 'equal)))
         (funcall (intern choice) bible-version reference-normal))))

(defun goto-bible-reference (bible-version reference)
(browse-url (format  "https://www.biblegateway.com/bible?language=en&version=%s&passage=%s" bible-version reference)))

(defun copy-scripture (bible-version reference-normal)
(async-shell-command-to-string (concat "bible " reference-normal " --version " bible-version " --verse-numbers")
                                   (lambda (str)
                                   (evil-set-register ?\" str
                                                      ))))

(defun org-bible-export (passage description format _)
  (let* ((cooler-passage (replace-regexp-in-string "^\\(.+[0-9]\\)\\s-\\(.*\\)" "\\1,\\2" passage))
         (split-passage (split-string cooler-passage ","))
         (bible-version (or (nth 1 split-passage) "NIV"))
         (reference (nth 0 split-passage))
         (reference-clean (replace-regexp-in-string " " "\+" (nth 0 split-passage)))
         (link (format "https://www.biblegateway.com/bible?language=en&version=%s&passage=%s" bible-version reference-clean))
         (desc ( or description (format "%s (%s)" reference bible-version)))
         )
    (pcase format
      (`html (format "<a target=\"_blank\" href=\"%s\">%s</a>" link desc))
      (`latex (format "\\textbf{\\href{%s}{%s}}" link desc))
      (`texinfo (format "@uref{%s,%s}" link desc))
      (`ascii (format "%s (%s)" desc link))
      (`md (format "**[%s](%s)**" desc link))
      (_ path))))

;; Code by me

(defun is-link-of-type (link prefix)
  (when (string-match (rx (literal prefix)
                          ":"
                          (group (1+ anything))) link)
    t))
(defun get-link-type (link)
  (when (string-match (rx (group (1+ (not ":")))
                          ":"
                          (1+ anything)) link)
    (match-string 1 link)))
(defun omit-link-type (link)
  (when (string-match (rx (0+ (not ":"))
                          ":"
                          (group (1+ anything))) link)
    (match-string 1 link)))

(defun bible-protocol-open (passage)
  (let* ((cooler-passage (replace-regexp-in-string "^\\(.+[0-9]\\)\\s-\\(.*\\)" "\\1,\\2" passage))
         (split-passage (split-string cooler-passage ","))
         (bible-version (or (nth 1 split-passage) "NASB"))
         (reference-normal (nth 0 split-passage))
         (reference (replace-regexp-in-string " " "\+" (nth 0 split-passage)))
         (url "https://www.biblegateway.com/bible?language=en&version=%s&passage=%s")
         )
    (async-shell-command-to-string (concat "bible " reference-normal " --version " bible-version " --verse-numbers")
                                   (lambda (str)
                                   (evil-set-register ?\" str
                                                      )))))

(defvar +custom/org-find-file-at-mouse-called nil
  "Indicates if the `org-open-at-point' was call through `org-find-file-at-mouse'")

(defun org-find-file-at-mouse-a (fn &rest args)
  (setq +custom/org-find-file-at-mouse-called t)
  (prog1 (apply fn args)
    (setq +custom/org-find-file-at-mouse-called nil)))

(advice-add #'org-find-file-at-mouse :around #'org-find-file-at-mouse-a)

(defun open-custom-link-h ()
  (when +custom/org-find-file-at-mouse-called
    (let* ((context
            ;; Only consider supported types, even if they are not the
            ;; closest one.
            (org-element-lineage
             (org-element-context)
             '(link)
             t))
           (type (org-element-type context))
           (raw-link (org-element-property :raw-link context)))
      (when (eq type 'link)
        (let* ((address (omit-link-type raw-link))
               (link-protocol (get-link-type raw-link)))
          (pcase link-protocol
            ("bible" (bible-protocol-open address))
            ("stop" (message "Lol cool"))
            ))))))

(add-hook! 'org-open-at-point-functions #'open-custom-link-h)
)
(add-hook 'text-mode-hook #'auto-fill-mode)
(setq-default fill-column 80)
(remove-hook 'doom-first-input-hook #'evil-snipe-mode)

(if (not IS-MAC)
(setq select-enable-clipboard nil))

(setq display-line-numbers-type 'relative)




(setq confirm-kill-emacs nil)

;;; mani.el --- A tiny Man page reader -*- lexical-binding: t -*-

;; Copyright (C) 2019 Fan Yang

;; Author: Fan Yang <Fan_Yang@sjtu.edu.cn>
;; Created: 20 Dec 2019
;; Homepage: https://github.com/Raphus-cucullatus/mani.el
;; Keywords: extensions
;; Version: prerelease

;;; Commentary:

;; "Why not `man.el' or `woman.el'"?
;;
;; 1. `man.el' does not support remote Man page.
;;
;;   I frequently work in a remote environment (with TRAMP): a remote
;;   machine (usually Linux), from a macOS laptop.
;;
;;   In that case, I prefer seeing Man pages in that machine,
;;   e.g. Linux system calls instead of BSD ones, and tools installed
;;   on servers not on my laptop.
;;
;; 2. One can manage `woman.el' to find remote man page file, but
;; `woman.el' does not always parse correctly.
;;
;;  For example, "woman ls" produces the following sequences in my
;;  machine:
;;
;;    .Dd May 19, 2002
;;    .Dt LS 1
;;    .Os
;;    .Sh NAME
;;    .Nm ls
;;    .Nd list directory contents
;;    ...
;;
;;
;; `mani.el' is a just-work Man page reader:
;; 
;; 1. It invokes the `man' program to produce the content.  So if
;; `man' works, `mani.el' works.
;;
;; 2. It uses `process-file' to run the `man' program.  So it is
;; "remote-aware".  If the current `default-directory' is a remote
;; one, `man' is invoked in that remote machine.
;;
;;
;; Limitations
;;
;; `mani.el' is not any feature-rich like `man.el' and `woman.el'.  It
;; does not support navigation, completion, highlight, and caching
;; functionalities.  I find it just work, and am less-motivated to
;; push it further.
;;
;;
;;; Code:

(defun mani-fontify ()
  "Convert overstriking and underlining to the correct fonts.
Same for the ANSI bold and normal escape sequences.

This defun is adapted from man.el."
  (goto-char (point-min))
  ;; Fontify ANSI escapes.
  (let ((ansi-color-apply-face-function #'ansi-color-apply-text-property-face))
    (ansi-color-apply-on-region (point-min) (point-max)))
  ;; Other highlighting.
  (let ((buffer-undo-list t))
    (if (< (buffer-size) (position-bytes (point-max)))
	;; Multibyte characters exist.
	(progn
	  (goto-char (point-min))
	  (while (and (search-forward "__\b\b" nil t) (not (eobp)))
	    (backward-delete-char 4)
            (put-text-property (point) (1+ (point))
                               'font-lock-face 'underline))
	  (goto-char (point-min))
	  (while (search-forward "\b\b__" nil t)
	    (backward-delete-char 4)
            (put-text-property (1- (point)) (point)
                               'font-lock-face 'underline))))
    (goto-char (point-min))
    (while (and (search-forward "_\b" nil t) (not (eobp)))
      (backward-delete-char 2)
      (put-text-property (point) (1+ (point)) 'font-lock-face 'underline))
    (goto-char (point-min))
    (while (search-forward "\b_" nil t)
      (backward-delete-char 2)
      (put-text-property (1- (point)) (point) 'font-lock-face 'underline))
    (goto-char (point-min))
    (while (re-search-forward "\\(.\\)\\(\b+\\1\\)+" nil t)
      (replace-match "\\1")
      (put-text-property (1- (point)) (point) 'font-lock-face 'bold))
    (goto-char (point-min))
    (while (re-search-forward "o\b\\+\\|\\+\bo" nil t)
      (replace-match "o")
      (put-text-property (1- (point)) (point) 'font-lock-face 'bold))
    (goto-char (point-min))
    (while (re-search-forward "[-|]\\(\b[-|]\\)+" nil t)
      (replace-match "+")
      (put-text-property (1- (point)) (point) 'font-lock-face 'bold))
    (goto-char (point-min))
    (while (re-search-forward ".\b" nil t) (backward-delete-char 2))
    (goto-char (point-min))
    (unless (eq t (compare-strings "latin-" 0 nil
				   current-language-environment 0 6 t))
      (goto-char (point-min))
      (while (search-forward "­" nil t) (replace-match "-")))
    (goto-char (point-min))
    (while (re-search-forward "^\\([[:upper:]][[:upper:]0-9 /-]+\\)$" nil t)
      (put-text-property (match-beginning 0)
			 (match-end 0)
			 'font-lock-face 'bold))))

;;;###autoload
(defun mani (man-cmd)
  "Display manual page specified by MAN-CMD.

The MAN-CMD is fed to `man'."
  (interactive "sMan: ")
  (let* ((buf (get-buffer-create (format "*Mani*" man-cmd)))
	 (curr-dir default-directory))
    (with-current-buffer buf
      (let ((inhibit-read-only t)
	    (default-directory curr-dir))
	(erase-buffer)
	(apply 'process-file "man" nil t nil (split-string man-cmd))
	(mani-fontify)
	(beginning-of-buffer))
      (view-mode))
    (display-buffer buf '((display-buffer-pop-up-window)))))

(provide 'mani)

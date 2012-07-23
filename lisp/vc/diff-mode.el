;; Copyright (C) 1998-2012 Free Software Foundation, Inc.
;; Some efforts were spent to have it somewhat compatible with XEmacs's
  '(("n" . diff-hunk-next)
    ("}" . diff-file-next)	; From compilation-minor-mode.
    ("o" . diff-goto-source)	; other-window
    ("R" . diff-reverse-direction)
    ("/" . diff-undo)
    ([remap undo] . diff-undo))
               (dolist (key '("A" "r" "R" "g" "q" "W" "z"))
    (condition-case-unless-debug nil (diff-refine-hunk) (error nil))))
    (((class color))
    (((class color))
  '((default
     :inherit diff-changed)
    (((class color) (min-colors 88) (background light))
     :background "#ffdddd")
    (((class color) (min-colors 88) (background dark))
     :background "#553333")
    (((class color))
     :foreground "red"))
  '((default
     :inherit diff-changed)
    (((class color) (min-colors 88) (background light))
     :background "#ddffdd")
    (((class color) (min-colors 88) (background dark))
     :background "#335533")
    (((class color))
     :foreground "green"))
    (((class color))
     :foreground "yellow"))
(defvar diff-use-changed-face (and (face-differs-from-default-p diff-changed-face)
				   (not (face-equal diff-changed-face diff-added-face))
				   (not (face-equal diff-changed-face diff-removed-face)))
  "If non-nil, use the face `diff-changed' for changed lines in context diffs.
Otherwise, use the face `diff-removed' for removed lines,
and the face `diff-added' for added lines.")

     (1 (if diff-use-changed-face
	    diff-indicator-changed-face
	  ;; Otherwise, search for `diff-context-mid-hunk-header-re' and
	  ;; if the line of context diff is above, use `diff-removed-face';
	  ;; if below, use `diff-added-face'.
	  (save-match-data
	    (let ((limit (save-excursion (diff-beginning-of-hunk))))
	      (if (save-excursion (re-search-backward diff-context-mid-hunk-header-re limit t))
		  diff-indicator-added-face
		diff-indicator-removed-face)))))
     (2 (if diff-use-changed-face
	    diff-changed-face
	  ;; Otherwise, use the same method as above.
	  (save-match-data
	    (let ((limit (save-excursion (diff-beginning-of-hunk))))
	      (if (save-excursion (re-search-backward diff-context-mid-hunk-header-re limit t))
		  diff-added-face
		diff-removed-face))))))
    ("^\\(?:Index\\|revno\\): \\(.+\\).*\n"
  "Advance to the end of the current hunk, and return its position."
  "Move back to the previous hunk beginning, and return its position.
If point is in a file header rather than a hunk, advance to the
next hunk if TRY-HARDER is non-nil; otherwise signal an error."
  (if (looking-at diff-hunk-header-re)
      (point)
       (unless try-harder
	 (error "Can't find the beginning of the hunk"))
       (diff-beginning-of-file-and-junk)
       (diff-hunk-next)
       (point)))))
     (condition-case-unless-debug nil (diff-refine-hunk) (error nil))))
 diff-file diff-file-header-re "file" diff-end-of-file)

(defun diff-bounds-of-hunk ()
  "Return the bounds of the diff hunk at point.
The return value is a list (BEG END), which are the hunk's start
and end positions.  Signal an error if no hunk is found.  If
point is in a file header, return the bounds of the next hunk."
  (save-excursion
    (let ((pos (point))
	  (beg (diff-beginning-of-hunk t))
	  (end (diff-end-of-hunk)))
      (cond ((>= end pos)
	     (list beg end))
	    ;; If this hunk ends above POS, consider the next hunk.
	    ((re-search-forward diff-hunk-header-re nil t)
	     (list (match-beginning 0) (diff-end-of-hunk)))
	    (t (error "No hunk found"))))))

(defun diff-bounds-of-file ()
  "Return the bounds of the file segment at point.
The return value is a list (BEG END), which are the segment's
start and end positions."
  (save-excursion
    (let ((pos (point))
	  (beg (progn (diff-beginning-of-file-and-junk)
		      (point))))
      (diff-end-of-file)
      ;; bzr puts a newline after the last hunk.
      (while (looking-at "^\n")
	(forward-char 1))
      (if (> pos (point))
	  (error "Not inside a file diff"))
      (list beg (point)))))
  (apply 'narrow-to-region
	 (if arg (diff-bounds-of-file) (diff-bounds-of-hunk)))
  (set (make-local-variable 'diff-narrowed-to) (if arg 'file 'hunk)))
  "Kill the hunk at point."
  (let* ((hunk-bounds (diff-bounds-of-hunk))
	 (file-bounds (ignore-errors (diff-bounds-of-file)))
	 ;; If the current hunk is the only one for its file, kill the
	 ;; file header too.
	 (bounds (if (and file-bounds
			  (progn (goto-char (car file-bounds))
				 (= (progn (diff-hunk-next) (point))
				    (car hunk-bounds)))
			  (progn (goto-char (cadr hunk-bounds))
				 ;; bzr puts a newline after the last hunk.
				 (while (looking-at "^\n")
				   (forward-char 1))
				 (= (point) (cadr file-bounds))))
		     file-bounds
		   hunk-bounds))
    (apply 'kill-region bounds)
    (goto-char (car bounds))))
  "diff \\|index \\|\\(?:deleted file\\|new\\(?: file\\)?\\|old\\) mode\\|=== modified file")
  (let ((inhibit-read-only t))
    (apply 'kill-region (diff-bounds-of-file))))
	(start (diff-beginning-of-hunk)))
         (let ((file (expand-file-name (or (first fs) ""))))
	   (setq file
		 (read-file-name (format "Use file %s: " file)
				 (file-name-directory file) file t
				 (file-name-nondirectory file)))
  (diff-setup-whitespace)
(defun diff-setup-whitespace ()
  "Set up Whitespace mode variables for the current Diff mode buffer.
This sets `whitespace-style' and `whitespace-trailing-regexp' so
that Whitespace mode shows trailing whitespace problems on the
modified lines of the diff."
  (set (make-local-variable 'whitespace-style) '(face trailing))
  (let ((style (save-excursion
		 (goto-char (point-min))
		 (when (re-search-forward diff-hunk-header-re nil t)
		   (goto-char (match-beginning 0))
		   (diff-hunk-style)))))
    (set (make-local-variable 'whitespace-trailing-regexp)
	 (if (eq style 'context)
	     "^[-\+!] .*?\\([\t ]+\\)$"
	   "^[-\+!<>].*?\\([\t ]+\\)$"))))

	   (char-offset (- (point) (diff-beginning-of-hunk t)))
  (let* ((char-offset (- (point) (diff-beginning-of-hunk t)))
     :background "#ffff55")
     :background "#aaaa22")
    (t :inverse-video t))
(defface diff-refine-removed
  '((default
     :inherit diff-refine-change)
    (((class color) (min-colors 88) (background light))
     :background "#ffaaaa")
    (((class color) (min-colors 88) (background dark))
     :background "#aa2222"))
  "Face used for removed characters shown by `diff-refine-hunk'."
  :group 'diff-mode
  :version "24.2")

(defface diff-refine-added
  '((default
     :inherit diff-refine-change)
    (((class color) (min-colors 88) (background light))
     :background "#aaffaa")
    (((class color) (min-colors 88) (background dark))
     :background "#22aa22"))
  "Face used for added characters shown by `diff-refine-hunk'."
  :group 'diff-mode
  :version "24.2")

                  (beg1 end1 beg2 end2 props-c &optional preproc props-r props-a))
    (diff-beginning-of-hunk t)
           (props-c '((diff-mode . fine) (face diff-refine-change)))
           (props-r '((diff-mode . fine) (face diff-refine-removed)))
           (props-a '((diff-mode . fine) (face diff-refine-added)))
                                nil 'diff-refine-preproc props-r props-a)))
                                  (if diff-use-changed-face props-c)
                                  'diff-refine-preproc
                                  (unless diff-use-changed-face props-r)
                                  (unless diff-use-changed-face props-a)))))
                                  nil 'diff-refine-preproc props-r props-a))))))))
(defun diff-undo (&optional arg)
  "Perform `undo', ignoring the buffer's read-only status."
  (interactive "P")
  (let ((inhibit-read-only t))
    (undo arg)))
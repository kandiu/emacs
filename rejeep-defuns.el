;;; rejeep-defuns.el --- Custom functions


(defun nuke-all-buffers ()
  "Kill all buffers, leaving *scratch* only."
  (interactive)
  (mapc
   (lambda (x)
     (kill-buffer x))
   (buffer-list))
  (delete-other-windows))

(defun open-line-below ()
  "Open a line below the line the point is at.
Then move to that line and indent accordning to mode"
  (interactive)
  (cond ((eq major-mode 'coffee-mode)
         (let ((column
                (save-excursion
                  (back-to-indentation)
                  (current-column))))
           (move-end-of-line 1)
           (newline)
           (move-to-column column t)))
        (t
         (move-end-of-line 1)
         (newline)
         (indent-according-to-mode))))

(defun open-line-above ()
  "Open a line above the line the point is at.
Then move to that line and indent accordning to mode"
  (interactive)
  (cond ((eq major-mode 'coffee-mode)
         (let ((column
                (save-excursion
                  (back-to-indentation)
                  (current-column))))
           (move-beginning-of-line 1)
           (newline)
           (forward-line -1)
           (move-to-column column t)))
        (t
         (move-beginning-of-line 1)
         (newline)
         (forward-line -1)
         (indent-according-to-mode))))

;; NOTE: (region-beginning) and (region-end) are not saved in
;; variables since they can change after each clean step.
(defun clean-up-buffer-or-region ()
  "Untabifies, indents and deletes trailing whitespace from buffer or region."
  (interactive)
  (save-excursion
    (unless (region-active-p)
      (mark-whole-buffer))
    (untabify (region-beginning) (region-end))
    (indent-region (region-beginning) (region-end))
    (save-restriction
      (narrow-to-region (region-beginning) (region-end))
      (delete-trailing-whitespace))))

(defun back-to-indentation-or-beginning-of-line ()
  "Moves point back to indentation if there is any
non blank characters to the left of the cursor.
Otherwise point moves to beginning of line."
  (interactive)
  (if (= (point) (save-excursion (back-to-indentation) (point)))
      (beginning-of-line)
    (back-to-indentation)))

(defun match-paren (arg)
  "Go to the matching paren if on a paren; otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1))
        ((looking-back "\\s\)") (backward-list 1))
        (t (self-insert-command arg))))

(defun duplicate-current-line-or-region (arg)
  "Duplicates the current line or region ARG times.
If there's no region, the current line will be duplicated. However, if
there's a region, all lines that region covers will be duplicated."
  (interactive "p")
  (let (beg end (origin (point)))
    (if (and (region-active-p) (> (point) (mark)))
        (exchange-point-and-mark))
    (setq beg (line-beginning-position))
    (if (region-active-p)
        (exchange-point-and-mark))
    (setq end (line-end-position))
    (let ((region (buffer-substring-no-properties beg end)))
      (dotimes (i arg)
        (goto-char end)
        (newline)
        (insert region)
        (setq end (point)))
      (goto-char (+ origin (* (length region) arg) arg)))))

(defun swap-windows ()
  "If you have 2 windows, it swaps them."
  (interactive)
  (cond ((/= (count-windows) 2)
         (message "You need exactly 2 windows to do this."))
        (t
         (let* ((w1 (first (window-list)))
                (w2 (second (window-list)))
                (b1 (window-buffer w1))
                (b2 (window-buffer w2))
                (s1 (window-start w1))
                (s2 (window-start w2)))
           (set-window-buffer w1 b2)
           (set-window-buffer w2 b1)
           (set-window-start w1 s2)
           (set-window-start w2 s1))))
  (other-window 1))

(defun rename-this-buffer-and-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (cond ((get-buffer new-name)
               (error "A buffer named '%s' already exists!" new-name))
              (t
               (rename-file filename new-name 1)
               (rename-buffer new-name)
               (set-visited-file-name new-name)
               (set-buffer-modified-p nil)
               (message "File '%s' successfully renamed to '%s'" name (file-name-nondirectory new-name))))))))

(defun delete-this-buffer-and-file ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (when (yes-or-no-p "Are you sure you want to remove this file? ")
        (delete-file filename)
        (kill-buffer buffer)
        (message "File '%s' successfully removed" filename)))))

(defun google ()
  "Googles a query or region if any."
  (interactive)
  (browse-url
   (concat
    "http://www.google.com/search?ie=utf-8&oe=utf-8&q="
    (if (region-active-p)
        (buffer-substring (region-beginning) (region-end))
      (read-string "Query: ")))))

(defun comment-or-uncomment-current-line-or-region ()
  "Comments or uncomments current current line or whole lines in region."
  (interactive)
  (save-excursion
    (let (min max)
      (if (region-active-p)
          (setq min (region-beginning) max (region-end))
        (setq min (point) max (point)))
      (comment-or-uncomment-region
       (progn (goto-char min) (line-beginning-position))
       (progn (goto-char max) (line-end-position))))))

(defun join-line-or-lines-in-region ()
  "Join this line or the lines in the selected region."
  (interactive)
  (cond ((region-active-p)
         (let ((min (line-number-at-pos (region-beginning))))
           (goto-char (region-end))
           (while (> (line-number-at-pos) min)
             (join-line))))
        (t (call-interactively 'join-line))))

(defun scroll-down-five ()
  "Scrolls down five rows."
  (interactive)
  (scroll-down 5))

(defun scroll-up-five ()
  "Scrolls up five rows."
  (interactive)
  (scroll-up 5))

(defun re-builder-large ()
  "Just like `re-builder', only make the font and window larger."
  (interactive)
  (re-builder)
  (text-scale-increase 5)
  (set-window-text-height (selected-window) 7))

(defun url-decode-region (beg end)
  (interactive "r")
  (let ((content (url-unhex-string (buffer-substring beg end))))
    (goto-char end)
    (newline)
    (insert content)))

(defun url-encode-region (beg end)
  (interactive "r")
  (let ((content (url-hexify-string (buffer-substring beg end))))
    (goto-char end)
    (newline)
    (insert content)))

(defun dired-open-marked-files ()
  "Open marked files."
  (interactive)
  (let ((distinguish-one-marked nil))
    (mapc 'find-file
          (dired-map-over-marks (dired-get-file-for-visit)
                                current-prefix-arg))))

(defun find-project-root (&optional dir)
  (interactive)
  (unless dir (setq dir (f-dirname (buffer-file-name))))
  (let ((parent (f-parent dir)))
    (unless (f-root? parent)
      (if (f-exists? (f-expand ".git" dir))
          dir
        (find-project-root parent)))))

(defun projectile-completion-fn (prompt choises)
  "Projectile completion function that only shows file name.

If two files have same name, new completion appears to select between
them. These include the path relative to the project root."
  (interactive)
  (let* ((choises
          (-uniq (-map 'f-filename choises)))
         (choise
          (ido-completing-read prompt choises))
         (matching-files
          (-filter
           (lambda (file)
             (equal (f-filename file) choise))
           (gethash (projectile-project-root) projectile-projects-cache))))
    (if (> (length matching-files) 1)
        (ido-completing-read
         prompt
         (-map
          (lambda (matching-file)
            (f-relative matching-file (projectile-project-root)))
          matching-files))
      (car matching-files))))

(provide 'rejeep-defuns)

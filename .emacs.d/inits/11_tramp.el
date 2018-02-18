(require 'tramp)
;(add-to-list 'backup-directory-alist
;  (cons tramp-file-name-regexp nil))
(add-to-list 'backup-directory-alist
  (cons "." "~/.emacs.d/backups/"))
(setq tramp-backup-directory-alist backup-directory-alist)
;; display hostname on frame
(defun my-tramp-hostname ()
  "tramp host name."
  (if (buffer-file-name)
      (if (string-match "\\`/\\([^[/:]+\\|[^/]+]\\):" (buffer-file-name))
          (tramp-file-name-host (tramp-dissect-file-name (buffer-file-name)))
        "local") nil ))
(setq frame-title-format '("%b - " (:eval (my-tramp-hostname))))

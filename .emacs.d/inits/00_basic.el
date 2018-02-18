(column-number-mode t)
(setq initial-scratch-message "")

(global-set-key "\C-\\" 'undo)
(global-set-key "\C-cg" 'goto-line)
(global-set-key "\C-h"  'delete-backward-char)

;; invalid auto-save
(setq auto-save-default nil)

;; delete region
(delete-selection-mode t)

;; clipbord
(set-clipboard-coding-system 'utf-8)
(setq x-select-enable-clipboard t)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

;; Do not use gpg agent when runing in terminal
(defadvice epg--start (around advice-epg-disable-agent activate)
  (let ((agent (getenv "GPG_AGENT_INFO")))
    (setenv "GPG_AGENT_INFO" nil)
    ad-do-it
    (setenv "GPG_AGENT_INFO" agent)))

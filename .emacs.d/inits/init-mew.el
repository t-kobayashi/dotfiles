(setq mew-use-cached-passwd t)
(setq mew-use-master-passwd nil)
(setq mew-passwd-timer-unit 6000)
(setq mew-use-unread-mark t)

;; display html part
(condition-case nil
    (require 'mew-w3m)
  (file-error nil))

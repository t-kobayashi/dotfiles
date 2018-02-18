(autoload 'php-mode "php-mode")
(setq auto-mode-alist
      (cons '("\\.php\\'" . php-mode) auto-mode-alist))
(setq php-mode-force-pear t)
(add-hook 'php-user-mode-hook
  '(lambda ()
     (c-set-style "stroustrup")
     (setq tab-width 4)
     (setq c-basic-offset 4)
     (setq indent-tabs-mode nil)
     (setq php-manual-path "/usr/local/share/php/doc/html")
     (setq php-manual-url "http://php.net/")
     ))
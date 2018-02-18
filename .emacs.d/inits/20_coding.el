;; coding style
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default c-basic-offset 4)

;; camel case <-> under score
;; http://d.hatena.ne.jp/kitokitoki/20091108/p6
(defun my-transform-LCC-underscore () 
  (interactive) 
  (labels 
    ((LCC-underscore (s1 s2) 
       (save-excursion 
         (replace-regexp
          s1
          (query-replace-compile-replacement s2 t)
          nil
          (car (bounds-of-thing-at-point 'symbol)) 
          (cdr (bounds-of-thing-at-point 'symbol)))))
    (strstr-at-point (s) 
      (save-excursion 
        (forward-symbol -1) 
        (if (search-forward-regexp s (cdr (bounds-of-thing-at-point 'symbol)) t) 
            t
          nil))))
    (cond ((strstr-at-point "_") 
           (LCC-underscore "_\\([a-z]\\)" "\\,(upcase \\1)"))
          ((strstr-at-point "\\([A-Z]\\)") 
           (LCC-underscore "\\([A-Z]\\)" "_\\,(downcase \\1)")))))
(global-set-key (kbd "M-8") 'my-transform-LCC-underscore)

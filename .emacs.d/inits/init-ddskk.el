;; skk
(set-input-method "japanese-skk")
(inactivate-input-method)

(global-set-key "\C-x\C-j" 'skk-mode)
(global-set-key "\C-xj" 'skk-auto-fill-mode)
(global-set-key "\C-xt" 'skk-tutorial)
(setq skk-use-jisx0201-input-method t)

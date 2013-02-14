;; init file for mandoku
(require 'mandoku)
(require 'org-mandoku)

(dolist (dir (directory-files mandoku-text-dir nil "^[^.,].*"))
  (when (file-directory-p (concat mandoku-text-dir dir))
    (load (concat "mandoku-support-" dir) t )))


(global-set-key "\M-\_" 'mandoku-annotate)
;(setq mandoku-index-dir (expand-file-name "~/00scratch/index-skqs/"))
;(setq mandoku-index-dir (expand-file-name "/tmp/index/"))
;(setq mandoku-index-dir (expand-file-name "~/00scratch/index/"))
;(setq mandoku-index-dir (expand-file-name  (concat mandoku-base-dir "index/")))


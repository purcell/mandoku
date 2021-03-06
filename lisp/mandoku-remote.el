;; mandoku.el   -*- coding: utf-8 -*-
;; created [2013-08-30T11:41:45+0900] chris
;; mandoku library for handling requests to remote host

(require 'url-http)
;; probably best to make this a list sometime...
(defvar mandoku-repositories-alist nil)
;(defvar mandoku-remote-url "http://localhost:5000/search")
;(setq mandoku-remote-url "http://127.0.0.1:5000")

(defun mandoku-search-remote (search-string index-buffer)
  (with-current-buffer index-buffer 
    (dolist (rep mandoku-repositories-alist)
      (url-insert-file-contents (concat (car (cdr rep)) "/search?query=" search-string)
			      (lambda (status) (switch-to-buffer (current-buffer)))))))


(defun mandoku-open-remote-file (filename src page)
  (let* ((buffer (car (last (split-string filename "/"))))
	 (rep (car (split-string buffer "[0-9]")))
	 (rep-url (car (cdr (assoc rep mandoku-repositories-alist ))))
	 )
    (with-current-buffer (get-buffer-create buffer)
      (url-insert-file-contents (concat rep-url "/getfile?filename=" filename )
			      (lambda (status) (switch-to-buffer buffer))))
    (switch-to-buffer buffer)
    (setq buffer-file-name (concat mandoku-temp-dir buffer))
    (unless (file-directory-p mandoku-temp-dir)
      (make-directory mandoku-temp-dir t))
    (goto-char (point-min))
    (if (looking-at "\n")
	(delete-char 1))
    (save-buffer)
    (mandoku-view-mode)
    (mandoku-execute-file-search 
	 (if src 
	     (concat page "::" src)
	   page))
    ))


(provide 'mandoku-remote)

;;; mandoku-remote.el ends here

;;; mandoku-install.el
;; inspired by el-get
(setq mandoku-base-dir nil)
(let ((mandoku-root
       (file-name-as-directory
	(or (bound-and-true-p mandoku-base-dir)
	    (concat (file-name-as-directory user-emacs-directory) "mandoku")))))

  (when (file-directory-p mandoku-root)
    (add-to-list 'load-path (concat mandoku-root "mandoku/lisp")))

  ;; try to require mandoku, failure means we have to install it
  (unless (require 'mandoku nil t)
    (unless (file-directory-p mandoku-root)
      (make-directory mandoku-root t))

    (let* ((package   "mandoku")
	   (buf       (switch-to-buffer "*mandoku bootstrap*"))
	   (pdir      (file-name-as-directory (concat mandoku-root package)))
	   (git       (or (executable-find "git")
			  (error "Unable to find `git'")))
	   (url       (or (bound-and-true-p mandoku-git-install-url)
			  "http://github.com/cwittern/mandoku.git"))
	   (default-directory mandoku-root)
	   (process-connection-type nil)   ; pipe, no pty (--no-progress)

	   ;; First clone mandoku
	   (status
	    (call-process
	     git nil `(,buf t) t "--no-pager" "clone" "-v" url package)))

      (unless (zerop status)
	(error "Couldn't clone mandoku from the Git repository: %s" url))

      ;; switch branch if we have to
      (let* ((branch (cond
                      ;; Check if a specific branch is requested
                      ((bound-and-true-p mandoku-install-branch))
                      ;; Check if master branch is requested
                      ((boundp 'mandoku-master-branch) "master")
                      ;; Read the default branch from the mandoku recipe
                      ((plist-get (with-temp-buffer
                                    (insert-file-contents-literally
                                     (expand-file-name "recipes/mandoku.rcp" pdir))
                                    (read (current-buffer)))
                                  :branch))
                      ;; As a last resort, use the master branch
                      ("master")))
             (remote-branch (format "origin/%s" branch))
             (default-directory pdir)
             (bstatus
               (if (string-equal branch "master")
                 0
                 (call-process git nil (list buf t) t "checkout" "-t" remote-branch))))
        (unless (zerop bstatus)
          (error "Couldn't `git checkout -t %s`" branch)))

      (add-to-list 'load-path pdir)
      (load package)
      (let ((mandoku-default-process-sync t) ; force sync operations for installer
            (mandoku-verbose t))		    ; let's see it all
        (mandoku-post-install "mandoku"))
      (unless (boundp 'mandoku-install-skip-emacswiki-recipes)
        (mandoku-emacswiki-build-local-recipes))
      (with-current-buffer buf
	(goto-char (point-max))
	(insert "\nCongrats, mandoku is installed and ready to serve!")))))

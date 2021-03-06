;;;; "mkimpcat.scm" Build mzscheme-specific catalog for SLIB.
;;; This code is in the public domain.
;;; Author: Aubrey Jaffer.

(let ((catname "implcat"))
  (define ivcatname (in-vicinity (implementation-vicinity) catname))
  (if (file-exists? ivcatname) (delete-file ivcatname))
  (call-with-output-file ivcatname
    (lambda (op)
      (define (display* . args)
	(for-each (lambda (arg) (display arg op)) args)
	(newline op))
      (define (add-alias from to)
	(display " " op)
	(write (cons from to) op)
	(newline op))
      (define (add-srfi feature)
	(let ((str (symbol->string feature)))
	  (define len (string-length str))
	  (cond ((not (and (> len 5)
			   (string-ci= "srfi-" (substring str 0 5))))
		 (error 'add-srfi 'bad 'srfi 'name feature)))))

      (display* ";\"" catname "\" Implementation-specific SLIB catalog for "
		(scheme-implementation-type) (scheme-implementation-version)
		".  -*-scheme-*-")
      (display* ";")
      (display* ";			DO NOT EDIT THIS FILE")
      (display* "; it is automagically generated by \""
		(current-load-relative-directory)
		"mkimpcat.scm"
		"\"")
      (display*)

      ;;; Output association lists to file "implcat"
      (display* "(")
      (do ((kdx 0 (+ 1 kdx)))
	  ((>= kdx 150))
	(let ((kstr (number->string kdx)))
	  (cond ((file-exists?
		  (build-path (collection-path "srfi")
			      (string-append kstr ".ss")))
		 (display " " op)
		 (write `(,(string->symbol (string-append "srfi-" kstr))
			  compiled
			  (lib ,(string-append kstr ".ss") "srfi"))
			op)
		 (newline op)))))

      (if (string>? (version) "370")
	  (add-alias 'array 'srfi-63))
      (add-alias 'logical 'srfi-60)
      (display* ")")
      )))

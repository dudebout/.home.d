;;; gtb-tests.el --- Tests for gtb.el

;;; Commentary:

;;; Code:

(require 'ert)
(require 'gtb)

(defun gtb-has-bucket-property (bucket-name)
  "Return t if the entry at point has the bucket property BUCKET-NAME."
  (equal bucket-name (org-entry-get (point) "bucket" t)))

(ert-deftest end-to-end-test ()
  (find-file "./gtb-tests.org")
  (gtb-total-buckets
   '(("bucket a"
      ((project1 . 1) (project2 . 9))
      (lambda () (gtb-has-bucket-property "a")))
     ("bucket b"
      project1
      (lambda () (gtb-has-bucket-property "b")))
     ("bucket c"
      overhead
      (lambda () (gtb-has-bucket-property "c"))
      t)))
  (let ((expected (progn
                    (find-file "./gtb-tests.golden")
                    (buffer-string)))
        (got (with-current-buffer (gtb-buffer)
               (buffer-string))))
    (should (equal got expected))))

;;; gtb-tests.el ends here

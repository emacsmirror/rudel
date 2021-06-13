;;; jupiter-insert.el --- Jupiter insert operation  -*- lexical-binding:t -*-
;;
;; Copyright (C) 2009-2021  Free Software Foundation, Inc.
;;
;; Author: Jan Moringen <scymtym@users.sourceforge.net>
;; Keywords: jupiter, operation, insert
;; X-RCS: $Id:$
;;
;; This file is part of Rudel.
;;
;; Rudel is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; Rudel is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with Rudel. If not, see <http://www.gnu.org/licenses>.


;;; Commentary:
;;
;; Class `jupiter-insert' implements an insert operation for the
;; Jupiter algorithm.


;;; History:
;;
;; 0.1 - Initial version


;;; Code:
;;

(eval-when-compile (require 'cl-lib))
(require 'eieio)

(require 'rudel-operations)
(require 'jupiter-operation)
(require 'jupiter-nop)
(require 'jupiter-compound)


(cl-defmethod jupiter-transform ((this jupiter-insert) (other jupiter-insert))
  ;; Transform an insert operation
  (with-slots ((this-from   from)
	       (this-to     to)
	       (this-length length)
	       (this-data   data))
      this
    (with-slots ((other-from   from)
		 (other-to     to)
		 (other-length length)
		 (other-data   data))
	other
      (cond
       ;;
       ;; <other>
       ;;         <this>
       ;; No need to do anything in this case.
       ;; ((< other-from this-from))

       ;;
       ;;        <other>
       ;; <this>
       ;;
       ((> other-from this-from)
	(cl-incf other-from this-length))

       ;;
       ;; <other>
       ;; <this>
       ;; OTHER inserted at the same start position as we did. Since
       ;; the situation is symmetric in the location properties of
       ;; OTHER and THIS, we use the inserted data to construct an
       ;; ordering.
       ((= other-from this-from)
	(when (string< this-data other-data)
	  (cl-incf other-from this-length))))))
  other)

(cl-defmethod jupiter-transform ((this jupiter-insert) (other jupiter-delete))
  ;; Transform a delete operation
  (with-slots ((this-from   from)
	       (this-to     to)
	       (this-length length))
      this
    (with-slots ((other-from   from)
		 (other-to     to)
		 (other-length length))
	other
      (cond

       ;;
       ;; <other>
       ;;         <this>
       ;; just keep OTHER

       ;;
       ;; <other> and   <other> and        <other>
       ;; <this>      <this>        <this>
       ((>= other-from this-from)
	(cl-incf other-from this-length)
	(cl-incf other-to   this-length))

       ;;
       ;; <  other  >
       ;;   <this>
       ;; OTHER deleted a region that includes the point at which THIS
       ;; inserted in its interior. OTHER has to be split into one
       ;; deletion before and one delete after the inserted data.
       ((and (< other-from this-from) (> other-to this-to))
	(setq other
	      (jupiter-compound :children (list (jupiter-delete :from other-from
				                                :to   this-from)
				                (jupiter-delete :from this-to
				                                :to   (+ other-to this-length))))))
       )))
  other)

(provide 'jupiter-insert)
;;; jupiter-insert.el ends here

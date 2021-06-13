;;; adopted-delete.el --- Adopted delete operation  -*- lexical-binding:t -*-
;;
;; Copyright (C) 2009-2021 Free Software Foundation, Inc.
;;
;; Author: Jan Moringen <scymtym@users.sourceforge.net>
;; Keywords: rudel, adopted, algorithm, operation, delete
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
;; along with rudel. If not, see <http://www.gnu.org/licenses>.


;;; Commentary:
;;
;; Class `adopted-delete' implements a delete operation for the
;; Adopted algorithm.


;;; History:
;;
;; 0.1 - Initial version


;;; Code:
;;

(eval-when-compile (require 'cl-lib))
(require 'eieio)

(require 'rudel-operations)
(require 'adopted-operation)
(require 'adopted-insert)
(require 'adopted-nop)


(cl-defmethod adopted-transform ((this adopted-delete) (other adopted-insert))
  ;; Transform an insert operation
  (with-slots ((this-from from) (this-to to) (this-length length)) this
    (with-slots ((other-from from) (other-to to) (other-length length)) other
      (cond
       ;;
       ;; <other>
       ;;         <this>
       ;;
       ((<= other-to this-from))

       ;;        <other>
       ;; <this>
       ((> other-from this-to)
	(cl-decf other-from this-length))

       ;;   <other>
       ;; <  this  >
       ((and (> other-from this-from) (< other-to this-to))
	(setq other-from this-from))
       )))
  other)

(cl-defmethod adopted-transform ((this adopted-delete) (other adopted-delete))
  ;; Transform a delete operation
  (with-slots ((this-from from) (this-to to) (this-length length)) this
    (with-slots ((other-from from) (other-to to) (other-length length)) other
      (cond

       ;;        <other>
       ;; <this>
       ;; OTHER deleted a region after the region deleted by
       ;; THIS. Therefore OTHER has to be shifted by the length of
       ;; the deleted region.
       ((> other-from this-to)
	(cl-decf other-from this-length)
	(cl-decf other-to   this-length))

       ;; <other>
       ;;         <this>
       ;; OTHER deleted a region before the region affected by
       ;; THIS. That is not affected by THIS operation.
       ((<= other-to this-from))

       ;; <  other  >
       ;;   <this>
       ((and (>= other-from this-from) (>= other-to this-to))
	(cl-decf other-to this-length))

       ;; <other>
       ;;    <this>
       ((and (< other-from this-from) (< other-to this-to))
	(cl-decf other-to (- other-to this-to)))

       ;;    <other>
       ;; <this>
       ;; The region deleted by OTHER overlaps with the region
       ;; deleted by THIS, such that a part of the region of this is
       ;; before the region of OTHER. The first part of the region
       ;; deleted by OTHER has already been deleted. Therefore, the
       ;; start of OTHER has to be shifted by the length of the
       ;; overlap.
       ((and (< other-from this-to) (> other-to this-to))
	(setq other-from this-from)
	(cl-incf other-to   (+ other-from (- other-to this-to))))
       ;; (setq other-to (this-to - other-from))

       ;;   <other>
       ;; <  this   >
       ;; The region deleted by OTHER is completely contained in
       ;; the region affected by THIS. Therefore, OTHER must not
       ;; be executed.
       ((and (>= other-from this-from) (<= other-to this-to))
	(setq other (adopted-nop)))

       (t
	(error "logic error in adopted-delete::transform(adopted-delete)"))
       )))
  other)

(provide 'adopted-delete)
;;; adopted-delete.el ends here

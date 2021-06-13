;;; adopted-operation.el --- Base class for Adopted operations  -*- lexical-binding:t -*-
;;
;; Copyright (C) 2009-2021  Free Software Foundation, Inc.
;;
;; Author: Jan Moringen <scymtym@users.sourceforge.net>
;; Keywords: rudel, adopted, algorithm, operation
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


;;; History:
;;
;; 0.1 - Initial version


;;; Code:
;;

(require 'rudel)

(defclass adopted-operation (rudel-operation)
  ()
  "")

(defclass adopted-insert (adopted-operation
			  rudel-insert-op)
  ()
  "Objects of this class represent insertions into buffers.")

(defclass adopted-delete (adopted-operation
			  rudel-delete-op)
  ()
  "Objects of this class represent deletions in buffers.")

(cl-defgeneric adopted-transform (this other)
  "Transform OTHER so as to apply before THIS.
Returns operation such that the effect of applying it after THIS are equal to
applying OTHER before THIS unmodified.
In general, OTHER is destructively modified or replaced.")


(provide 'adopted-operation)
;;; adopted-operation.el ends here

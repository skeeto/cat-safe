;;; cat-safe.el --- protect your buffers from wandering cats

;; Copyright (C) 2010 Christopher Wellons <mosquitopsu@gmail.com>

;; This file is not part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Two steps,
;;
;;   1. Copy this file to somewhere in your load-path.
;;
;;   2. Add the following line to your .emacs file,
;;
;;     (require 'cat-safe)

;; If you have a cat you may sometimes find that your cat has wandered
;; across your keyboard, typing garbage into whatever application has
;; focus. This script will protect your Emacs buffers from this by
;; detecting cat-like typing and switching to a junk buffer, sending
;; keystrokes there instead.
;;
;; To return to your work, just kill the junk buffer.

(defvar cat-safe-time nil
  "The start time of the current string of key.")

(defvar cat-safe-last-key nil
  "Last key pressed.")

(defvar cat-safe-last-key-count 0
  "Number of times the last key has been pressed in a row.")

(defvar cat-safe-max-repeat-count 6
  "Threshold for cat detection.")

(defvar cat-safe-min-time 1
  "Minimum period of time, in seconds, for a key series before
safety procedures kick in.")

(defvar cat-safe-allowed-keys
  '("	"  ; tab
    " "    ; space
    ""   ; backspace
    "")  ; delete
  "These keys are allowed to be repeated as it's not uncommon for
humans to do this. But this also means your cat can mash them
too.")

(defun cat-safe-key-p (key)
  "Predicate for keys that we are most concerned about cat feet pressing."
  (and (stringp key)
       (not (member key cat-safe-allowed-keys))))

(defvar cat-safe-buffer-message
  "Uh oh! Looks like a cat has wandered across your keyboard!!!\n\n"
  "Message displayed in buffer used to capture cat keystrokes.")

(defun cat-safe-command-hook ()
  "Determines if latest keystrokes are actually cat feet."
  (let ((key (this-command-keys)))
					;(insert (prin1-to-string key))
    (if (not (cat-safe-key-p key))
	(setq cat-safe-last-key-count 0)
      (if (equal key cat-safe-last-key)
	  (setq cat-safe-last-key-count (1+ cat-safe-last-key-count))
	(setq cat-safe-last-key key
	      cat-safe-time (float-time)
	      cat-safe-last-key-count 0))
      (if (and
	   (> cat-safe-last-key-count cat-safe-max-repeat-count)
	   (< (- (float-time) cat-safe-time) cat-safe-min-time))
	  (cat-safe-activate-safety)))))

(defun cat-safe-activate-safety ()
  "Activate safety measures to reduce cat damage."
  (let ((buf (get-buffer-create "*cat-safe*")))
    (switch-to-buffer buf)
    (when (zerop (buffer-size))
      (insert cat-safe-buffer-message)
      (set-buffer-modified-p nil))))

(add-hook 'pre-command-hook 'cat-safe-command-hook)

(provide 'cat-safe)

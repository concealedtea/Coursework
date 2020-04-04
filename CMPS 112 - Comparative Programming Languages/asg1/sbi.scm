#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/racket/bin/mzscheme -qr
;; $Id: sbi.scm,v 1.4 2018-04-11 16:31:36-07 - - $
;;
;; NAME
;;    sbi.scm - silly basic interpreter
;;
;; SYNOPSIS
;;    sbi.scm filename.sbir
;;
;; DESCRIPTION
;;    The file mentioned in argv[1] is read and assumed to be an SBIR
;;    program, which is the executed.  Currently it is only printed.
;;
;; OPERANDS
;;    The single filename argument specifies an SBIR program to be run.
;;
;; EXIT STATUS
;;    If the program completes without error, 0 is returned. If not, 1 is returned.
;; This first part is basically all from Mackey's source code with minor changes posted at /afs/cats.ucsc.edu/courses/cmps112-wm/Languages/scheme/Examples

(define *stderr* (current-error-port))

(define *run-file*
    (let-values
        (((dirpath basepath root?)
            (split-path (find-system-path 'run-file))))
        (path->string basepath))
)

(define (die list)
    (for-each (lambda (item) (display item *stderr*)) list)
    (newline *stderr*)
    (exit 1)
)

(define (usage-exit)
    (die `("Usage: " ,*run-file* " filename"))
)

(define (readlist-from-inputfile filename)
    (let ((inputfile (open-input-file filename)))
        (if (not (input-port? inputfile))
            (die `(,*run-file* ": " ,filename ": open failed"))
            (let ((program (read inputfile)))
                (close-input-port inputfile)
                        program)))
)
;; From this part onwards, it's the assignment
;; Functions / Table of Operation Definitions

; *identifier-table* is used to hold all of the functions, which include the operators
; as well. This is initialized when the program begins using a for-each
; loop containing a lambda. (See the example symbols.scm). It also holds the
; value of all variables, including pi and e and is updated as needed during
; interpretation of the program. Arrays are created with make-vector and
; updated with vector-set!.
(define *identifier-table* (make-hash))

(define (symbol-put! key value)
        (hash-set! *identifier-table* key value)
)

(for-each
    (lambda (pair)
            (symbol-put! (car pair) (cadr pair)))
    `(
        (abs , abs) (acos , acos) (asin , asin) (atan , atan) (ceil , ceiling) (cos , cos) (exp , exp) (floor , floor) (log , log)
        (log10 , (lambda (x) (/ (log (+ x 0.0)) (log 10.0))))
        (log2 , (lambda (x) (/ (log (+ x 0.0)) (log 2.0))))
        (round , round) (sin , sin) (sqrt , sqrt) (tan , tan) (trunc , truncate)
        (div     , (lambda (x y) (/ (+ x 0.0) (+ y 0.0))))
        (mod     , (lambda (x y) (- x (* (div x y) y))))
        (quot    , (lambda (x y) (truncate (/ x y))))
        (rem     , (lambda (x y) (- x (* (quot x y) y))))
        (<>      , (lambda (x y) (not (= x y))))
        (+ , +) (- , -) (* , *) (/ , /) (<= , <=) (>= , >=) (= , =) (> , >) (< , <) (^ , expt)
        (e       2.718281828459045235360287471352662497757247093)
        (pi      3.141592653589793238462643383279502884197169399)
    )
)

; *native-table* is used to hold the native values to be interpreted by the scheme function
(define *native-table* (make-hash))

; *label-table* is used to hold addresses of each line, one level up from statements.
; This is initialized by scanning the list returned by (read) when the
; program begins.
(define *label-table* (make-hash))

; Checks the expression for evaluation
(define (expression_eval expr)
(cond
    ((string? expr) expr) ; String check 
    ((number? expr) expr) ; Number check
    ((hash-has-key? *identifier-table* expr) (hash-ref *identifier-table* expr)) ; HashK check
    ((list? expr) ; List check
    (if (hash-has-key? *identifier-table* (car expr))
        (let((head (hash-ref *identifier-table*  (car expr))))
        (cond 
            ((procedure? head)
            (apply head (map (lambda (x) (expression_eval x)) (cdr expr))))
            ((vector? head) (vector-ref head (cadr expr))) ; Within List check, Vector check
            ((number? head) head) ; Within List check, Number check
            (else (die "Invalid Expression, cannot be read")))) ; Error Message 
        ; Error Message containing missing expression
        (die (list "Invalid Expression " (car expr) " not in symbol indetification table!\n"))
    )
    )
)
)

; Print Function
(define (sb_print expr)
(map (lambda (x) (display (expression_eval x))) expr)
(newline)
)

; Dim Function to declare new arrays
(define (sb_dim expr) 
(set! expr (car expr))
(let((arr (make-vector (expression_eval (cadr expr)) (car expr)))) (symbol-put! (car expr) (+ (expression_eval (cadr expr)) 1)))
)

; Assigns Variable 
(define (sb_let expr)
(symbol-put! (car expr) (expression_eval (cadr expr)))
)

; Links to Assign an Input from User
; From SGT, written on board during one session
(define (sb_assigninput expr count)
(if (null? expr)
    count
    (let ((input (read)))
        (if (eof-object? input) -1
        (begin
            (symbol-put! (car expr) input)
            (set! count (+ 1 count))
            (sb_assigninput (cdr expr) count)
        )
        )
    )
)
)

; Takes input from User, used in test case for the Indiana Bill passing
; From SGT, written on board during one session
(define (sb_input expr) 
(symbol-put! 'inputcount 0)
(if (null? (car expr))
    (symbol-put! 'inputcount -1)
    (begin
    (symbol-put! 'inputcount (sb_assigninput expr 0)))
)
)

; Defines if native, else undefined
(define (sb_if op-label)
    (let ((expr (car op-label)) (label (cadr op-label)))
        (if (eval-expr expr)
            (if (hash-has-key? label-table label)
                (set! PC (hash-ref label-linenr label))
                (die `(,*run-file* ": if: " ,label " undefined"))
            )
            expr
        )
    )
)

; Defines goto native, else undefined
(define (sb_goto label)
    (if (hash-has-key? label-table (car label))
        (set! PC (hash-ref label-linenr (car label)))
        (die `(,*run-file* ": goto: " ,label " undefined"))
    )
)

; Execute line given from eval-line
(define (exec-line instr program line-nr)
(when (not (hash-has-key? *native-table* (car instr))) (die "~s is not a valid instruction." (car instr)))
(cond
    ((eq? (car instr) 'goto)
        (eval-line program (hash-ref *label-table* (cadr instr)))
    )
    ((eq? (car instr) 'if)
        (if (expression_eval (car (cdr instr))) 
        (eval-line program (hash-ref *label-table* (cadr (cdr instr)))) (eval-line program (+ line-nr 1))
        )
    )
    ((eq? (car instr) 'print)
        (if (null? (cdr instr))
        (newline)
        (sb_print (cdr instr))
        )
        (eval-line program (+ line-nr 1))
    )
    (else
        ((hash-ref *native-table* (car instr)) (cdr instr))
        (eval-line program (+ line-nr 1))
    )
)
)

; Take line #, evaluate contents of line
(define (eval-line program line-nr)
(when (> (length program) line-nr)
    (let((line (list-ref program line-nr)))
        (cond ((= (length line) 3)
            (set! line (cddr line)) (exec-line (car line) program line-nr)
        )
        ((and (= (length line) 2) (list? (cadr line)))
            (set! line (cdr line)) (exec-line (car line) program line-nr)
        )
        (else 
            (eval-line program (+ line-nr 1)))
        )
    )
)
)

; Function: Find the length of a list.
(define length
(lambda (ls)
    (if (null? ls)
        0
        (+ (length (cdr ls)) 1)
    )
)
)

; Push the labels into the hash table.
(define (hash-labels program)
(map (lambda (line) 
        (when (not (null? line))
            (when (or (= 3 (length line)) (and (= 2 (length line)) (not (list? (cadr line)))))
                (hash-set! *label-table* (cadr line) (- (car line) 1 ))
            )
        )
    ) program)
)

; Main Function, derived from Mackey's example 
(define (main arglist)
(if (or (null? arglist) (not (null? (cdr arglist))))
    (usage-exit)  
    (let* ((sbprogfile (car arglist))
            (program (readlist-from-inputfile sbprogfile))) 
        (hash-labels program)
        (eval-line program 0)
    )
)
)

; Silly Basic function -> Native Function Translator
; Maps the Silly Basic functions using hash-maps
(for-each
(lambda (pair)
        (hash-set! *native-table* (car pair) (cadr pair)))
`(
    (print ,sb_print)
    (dim   ,sb_dim)
    (let   ,sb_let)
    (input ,sb_input)
    (if    ,sb_if)
    (goto  ,sb_goto)
)
)
(main (vector->list (current-command-line-arguments)))
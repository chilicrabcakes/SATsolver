; Homework 4
; Create a SAT solver for CNF propositional logic statements

; Note to Grader: I realise my nomenclature may be confusing,
; I used delta to represent knowledge bases rather than CNF's
; which is different from how the sat? function is supposed 
; to be defined. This is because the professor wrote knowledge
; bases as delta in class so I used that before realizing what
; your nomenclature was. 


; DPLL Algorithm (From textbook):
; function DPLL(clauses, symbols,model) returns true or false
;   if every clause in clauses is true in model then return true
;   if some clause in clauses is false in model then return false
;      P, value = FIND-PURE-SYMBOL(symbols, clauses,model )
;   if P is non-null then return DPLL(clauses, symbols - P,model U {P=value})
;      P, value = FIND-UNIT-CLAUSE(clauses,model )
;   if P is non-null then return DPLL(clauses, symbols - P,model U {P=value})
;   P = FIRST(symbols); rest = REST(symbols)
;   return DPLL(clauses, rest ,model U {P=true}) or
;          DPLL(clauses, rest ,model U {P=false}))


; REMOVE-ELEMENT: Removes the specific element in the list, 
; returns a list without the element. Takes in two arguments:
; a list to be edited LST, and the position of the element to 
; be removed X.

(defun remove-element (lst x)
  (cond
    ((null lst) nil)
    ((< x 0) nil)
    ((> (- x 1) (length lst)) nil)
    (t 
     (append (butlast lst (- (length lst) x)) (nthcdr (+ 1 x) lst))))
)

; FIND-ELEM: Finds a specific type of element in a list, and returns true
; if it finds that element in the list. Takes in two arguments: the list LST,
; and the element the function is looking for N.

(defun find-elem (lst n)
  (cond
    ((null lst) nil)
    ((equal (car lst) n) t)
    (t (find-elem (cdr lst) n)))
)

; FIND-AND-REMOVE: Finds a specific element in a list, and removes ALL
; instances of it from the list. Takes in three arguments: The list in question
; LST, the element to be removed N, and X the number of elements (from top) to cover.
; (X is an argument to maintain the recursion, but  it can be used to skip positions
; already iterated through). 

(defun find-and-remove (lst n x)
  (cond
    ((null lst) nil) ; This just means that after removing all the elements nothing was left
    ((< x 1) lst)
    ((> x (length lst)) (find-and-remove lst n (length lst)))
    ((equal (car (nthcdr (- x 1) lst)) n) 
     (find-and-remove (remove-element lst (- x 1)) n (- x 1)))
    (t 
     (find-and-remove lst n (- x 1))))
)

; CHECK-CLAUSE-FOR-DELTA: Checks a single clause against a partial knowledge
; base delta. Takes in two arguments, a clause C, and a knowledge base DELTA.
; Returns:
; t if the clause is consistent with the knowledge base
; nil if the clause is inconsistent with the knowledge base
; otherwise, returns a 'simplified' clause back in which literals represented 
; in the knowledge base are removed. 

(defun check-clause-for-delta (c delta)
  (cond
    ((null delta) c)
    ((find-elem c (car delta)) t) 
    ((find-elem c (* (car delta) -1))
     (if (= (length c) 1) 
	 nil
	 (check-clause-for-delta (find-and-remove c (* (car delta) -1) (length c)) (cdr delta))))
    (t (check-clause-for-delta c (cdr delta))))
)


; SIMPLIFY: Simplifies CNF propositional statements given 
; a set of partial knowledge. Takes in three arguments, CNF,
; the propositional statement, DELTA, the partial knowledge base,
; and X, the number of clauses to check (from top) in the statement.
; (Again, X is used for recursion, but can be used to skip clauses from
; bottom). Helper function for dpll.

; Examples:
; (simplify '((1 2) (3 4)) '(1) '2) returns ((3 4)) as we know
; that 1 is true, so the entire first clause can be removed.
; (simplify '((-1 2) (3 4)) '(1) '2) returns ((2) (3 4)) as we
; know that 1 is false, so 2 must be true for the statement to hold.
; (simplify '((1)) '(1) '1) returns true.
; (simplify '((-1)) '(1) '1) returns false.

(defun simplify (cnf delta x)
  (cond
    ((null cnf) t) ; No clauses means all worlds are possible - i.e. no constraints no problems
    ((null delta) cnf) ; No partial knowledge means we know nothing and thus can't resolve any constraints
    ((< x 1) cnf) 
    ((> x (length cnf)) (simplify cnf delta (length cnf)))
    (t
     (let* ((c (car (nthcdr (- x 1) cnf))) (newc (check-clause-for-delta c delta)))
       (cond
	 ; This checks if a clause c is consistent with the knowledge base and removes c if it is.
	 ((equal newc t) (simplify (remove-element cnf (- x 1)) delta (- x 1)))
	 ; If a clause c is inconsistent with the knowledge base we return false.
	 ((null newc) nil) ; An inconsistent constraint will break the system
	 ; Otherwise, we keep going by replacing the old clause with the new one.
	 (t
	  (simplify (append (remove-element cnf (- x 1)) (list newc)) delta (- x 1))))))) ; Order of clauses doesn't matter 
)
	 
; UNIT-PROPAGATION: Checks if there are any unit (atomic) clauses in the 
; CNF statement, and adds them to delta (the partial knowledge base) if so. 
; Takes in two arguments, cnf and delta, and returns a new partial knowledge base.

(defun unit-propagation (cnf delta)
  (cond
    ((null cnf) delta)
    ((= 1 (length (car cnf)))
     (if (find-elem delta (car (car cnf)))
	 (unit-propagation (cdr cnf) delta)
	 (unit-propagation (cdr cnf) (append delta (car cnf)))))
    (t
     (unit-propagation (cdr cnf) delta)))
)

; CHOOSE-NEXT: Chooses a variable to pick next for the tree to generate children for.
; If xi is picked, then we try both if xi is true and if xi is false in DPLL. We pick
; an xi that is not yet covered in the knowledge base yet exists in the set of variables.

(defun choose-next (n delta)
  (cond
    ((null delta) n)
    ((< n 1) nil) ; The tree should never go this deep but in case
    ((find-elem delta n)
     (choose-next (- n 1) delta))
    ((find-elem delta (* n -1))
     (choose-next (- n 1) delta))
    (t n))
)


; DPLL: Function that implements the Davis-Putnam-Logemann-Loveland algorithm
; for solving CNF satisfiability problems. The algorithm is given as above.
; This function takes in three arguments, CNF, the conjunctive normal form
; of a propositional statement that is to be solved; DELTA, the partial 
; knowledge base (which can be null); and N, the number of variables in the
; CNF argument. Returns the acquired knowledge base DELTA if solvable,
; returns nil if not.

; My version of DPLL in pseudocode:
; DPLL(cnf, delta, n):
;  if cnf not null or  n < 1 return delta
;  upd = delta + (atomic clauses in cnf)
;  s = simplified clause (simplified using knowledge base)
;  xi = some pure symbol that has not yet been used
;  if goal state (that is, if all clauses are true) return true
;  if nil state (that is, if some clause is false) return false
;  Otherwise,
;     left = dpll(s, upd + xi, n - 1)
;     if left returns not null, then return left
;     right = dpll(s, upd + (-xi), n - 1)
;     if right returns not null, then return right
; return false

; By using simplify, which can return false if it finds inconsistency,
; and unit propagation, this algorithm does backtrack and maintain arc
; consistency. 

(defun dpll (cnf delta n)
  (cond
    ((null cnf) delta)
    ((< n 1) delta)
    (t
     (let* ((upd (unit-propagation cnf delta)) ; Generates unit-propagated delta.
	    (s (simplify cnf upd (length cnf))) ; Simplifies the clause given delta
	    (xi (choose-next n upd))) ; Picks a variable that has not yet been covered
       (cond
	 ; Expansion - checking for goal state
	 ((equal s t) upd) ; Solved! Go home.
	 ((null s) nil) ; Delta is inconsistent
	 (t
	  ; Here we are actually generating the tree
	  ; As per DFS rules, first it dives deep into the left side (positive side)
	  ; and then comes back and does the right side if it finds nothing on the left.
	  (let* ((left (dpll s (append upd (list xi)) (- n 1))))
	    (if left
		left
		(let* ((right (dpll s (append upd (list (* xi -1))) (- n 1))))
		  (if right
		      right
		      nil)))))))))
)

; COMPLETE: DPLL only gives a set of variables S such S => CNF where CNF is the 
; propositional statement. This function then adds those variables that are not covered
; by CNF. Takes in two arguments, N, the number of variables, and delta, the partial 
; knowledge base. As the arguments not in delta have no impact on the final output of
; the CNF, we can put them as either true or false.

(defun complete (delta n)
  (cond
    ((null delta) nil)
    ((< n 1) delta)
    ((find-elem delta n)
     (complete delta (- n 1)))
    ((find-elem delta (* n -1))
     (complete delta (- n 1)))
    (t
     (complete (append delta (list n)) (- n 1))))
)

; SAT? : The higher-level function required. SAT? is a SAT solver that
; takes in two arguments, n, the number of variables, and delta, the CNF
; propositional statements that this function must solve. Returns a set of 
; variables that solve this SAT problem. 

(defun sat? (n delta)
  (cond
    ((null delta) nil)
    ((< n 1) nil)
    (t
     (let* ((fin (dpll delta 'nil n)))
       (complete fin n))))
)
       

  
 

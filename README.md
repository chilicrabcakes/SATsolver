# SATsolver
A solver for the archetypal NP-Complete problem of satisfiability. Done as a homework assignment for UCLA's CS 161 - Fundamentals of Artificial Intelligence.

### What is the Satisfiability (SAT) problem?
The SAT problem is a typical problem taught in Computer Science classes. Effectively, the problem is - given a condition of boolean variables, return a set of values for those variables that makes the condition return true. This problem is NP, which means that no solution to this problem exists such that it can solve the problem in worse-case polynomial time. It is also complete, that is, all problems in the class of NP can be reduced to the SAT problem in polynomial time.

More information can be found here: https://www.cs.cmu.edu/afs/cs/project/jair/pub/volume10/hogg99a-html/node3.html

### How it works
The function sat? takes in two arguments - the number of variables in the input *n* (of type atom) and the set of CNF conditionals *delta* (of type list). The function uses the DPLL algorithm to solve the set of CNF conditionals and returns a set of values for the variables that satisfy the given condition.

### How the CNF conditionals are defined
The variables in the CNF must be defined as '1', '2', '3', ... 'n', and so forth. That is, the number '1' actually stands for the first variable in the CNF. These variables are boolean, i.e., they can take on only two values, true and false. In this program, we define '1' to be the 1st variable, and '-1' to be not('1'). 

Return value of the function: The function returns a list of numbers like (1 2 3) that represent the values that the specific variables '1', '2', and '3' must be set to. In this case a return value of (1 2 3) mean that all of '1', '2', and '3' must be set to true in order for the input CNF to be true. For example, if the return value is (-1 2 3) we know that '1' must be set to false while '2' and '3' must be set to true in order to satisfy the CNF. 

##### Examples:
CNF: 1, is just the propositional condition '1'. This returns (1), that is the value '1' must be set to true for this condition to be satisfied.
CNF: (1 2) (3 4) -> represents the propositional condition '(1 OR 2) AND (3 OR 4)'. Thus, a possible solution for this would be (1 3 2 4), or all four values set to true. Another possible solution would be (1 3 -2 -4) where '1' and '3' are true but '2' and '4' are false. 

### What you need:
- A CLISP compiler/interpreter (recommended GNU clisp, which can be found here: https://www.gnu.org/software/gcl/)

### How to run this program
- Compile the file using the command 
> (load "satsolver.lsp")
- give the command
> (sat? *number_of_variables* *cnf_condition*) 

##### Examples:
(sat? '1 (1)) returns (1) <br></br>
(sat? '4 ((1 2) (3 4)) returns (1 3 2 4)

### Speed
As of now, this program solves a conditional of size 100 in less than a tenth of a second.

Thank you!
For comments, compliments, or constructive criticism please email ayushlall@g.ucla.edu



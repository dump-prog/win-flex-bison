%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
%}

/* Declare token */
%token DT ID NUM EQ NE GE LE IF ELSE WHILE FOR INC DEC SWITCH CASE DEFAULT BREAK

%%
/* Grammar rules */
PROG: DT ID '(' ')' BLK 
  | error BLK {
  yyerror("Illegal main function definition!");
  yyerrok;
  }
  ;
BLK: '{' SS '}'
  | '{' '}'
  | '{' error '\n'{
  yyerror("Missing { in block!");
  yyerrok;
  }
  | error '}'{
  yyerror("Missing } in block!");
  yyerrok;
  }
  ;
SS: SS S 
  | S ;
S:  X ';'
  | DECL
  | IFST
  | WHILEST
  | FORST
  | SWITCHST
  | BLK
  ;
DECL: DT IDLIST ';' ;

IDLIST: ID
      | ID '=' E
      | IDLIST ',' ID
      | IDLIST ',' ID '=' E
      ;
IFST: IF '(' X ')' BLK
  |   IF '(' X ')' BLK ELSE BLK
  ;
WHILEST: WHILE '(' X ')' BLK
  ;
FORST: FOR '(' INIT ';' COND ';' STEP ')' BLK ;
INIT: DT ID '=' E
    | X
    | /* empty */
    ;
COND: E
    | /* empty */
    ;
STEP: E
    | /* empty */
    ;
SWITCHST: SWITCH '(' E ')' '{' CASELIST DEFAULTOPT '}'
        ;
CASELIST: CASELIST CASEBLOCK
        | CASEBLOCK
        ;

CASEBLOCK: CASE NUM ':' SS BREAKOPT
         ;

BREAKOPT: BREAK ';'
        | /* empty */
        ;

DEFAULTOPT: DEFAULT ':' SS
          | /* empty */
          ;
X: X '=' E
 | E
 ;
E: E EQ T
 | E NE T
 | T
 ;
T: T GE P
 | T LE P
 | T '>' P
 | T '<' P
 | P
 ;
P: P '+' A
 | P '-' A
 | A
 ;
A: A '*' B
 | A '/' B
 | B
 ;
B: C '^' B
 | C
 ;
C: ID
 | NUM
 | '(' E ')'
 | C INC
 | C DEC
 ;
%%

void yyerror(const char *s) {
    fprintf(stderr, "%s\n", s);
}
int main(){
	yyparse();
	return 0;
}

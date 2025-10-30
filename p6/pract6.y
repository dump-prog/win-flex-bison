%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char dtarr[100][50];
char idtype[100][50];
void yyerror(const char *s);
extern char currentDT[50];
extern int cnt;
extern char symTable[100][8];
%}

/* Declare token */
%token DT ID NUM EQ NE GE LE IF ELSE WHILE FOR INC DEC SWITCH CASE DEFAULT BREAK

%%
/* Grammar rules */
PROG: PROG FUNC 
    | FUNC
    ;
FUNC: DT ID '(' ')' BLK { 
if (idExists($2)) {
              char errmsg[100];
              sprintf(errmsg, "Error: Variable '%s' already declared", symTable[$2]);
              yyerror(errmsg);
              yyerrok;
          } else {
              strcpy(dtarr[$2], currentDT);
              strcpy(idtype[$2], "VariableName");
          }
}
    ;
BLK: '{' SS '}'
  | '{' '}'
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

IDLIST:
      ID {
          if (idExists($1)) {
              char errmsg[100];
              sprintf(errmsg, "Error: Variable '%s' already declared", symTable[$1]);
              yyerror(errmsg);
              yyerrok;
          } else {
              strcpy(dtarr[$1], currentDT);
              strcpy(idtype[$1], "VariableName");
          }
      }
    | ID '=' E {
          if (idExists($1)) {
              char errmsg[100];
              sprintf(errmsg, " Variable '%s' already declared", symTable[$1]);
              yyerror(errmsg);
              yyerrok;
          } else {
              strcpy(dtarr[$1], currentDT);
              strcpy(idtype[$1], "VariableName");
          }
      }
    | IDLIST ',' ID {
          if (idExists($3)) {
              char errmsg[100];
              sprintf(errmsg, "Error: Variable '%s' already declared", symTable[$3]);
              yyerror(errmsg);
              yyerrok;
          } else {
              strcpy(dtarr[$3], currentDT);
              strcpy(idtype[$3], "VariableName");
          }
      }
    | IDLIST ',' ID '=' E {
          if (idExists($3)) {
              char errmsg[100];
              sprintf(errmsg, "Error: Variable '%s' already declared", symTable[$3]);
              yyerror(errmsg);
              yyerrok;
          } else {
              strcpy(dtarr[$3], currentDT);
              strcpy(idtype[$3], "VariableName");
          }
      }
    ;

IFST: IF '(' X ')' BLK
  |   IF '(' X ')' BLK ELSE BLK
  ;
WHILEST: WHILE '(' X ')' BLK
  ;
FORST: FOR '(' INIT ';' COND ';' STEP ')' BLK ;
INIT: DT ID '=' E { strcpy(dtarr[$2], currentDT); strcpy(idtype[$2], "VariableName"); }
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
C: ID {
if(!idExists($1)){
	char errmsg[100];
        sprintf(errmsg, "Error: Variable '%s' undeclared", symTable[$1]);
        yyerror(errmsg);
        yyerrok;
	}
}
	
 | NUM
 | '(' E ')'
 | C INC
 | C DEC
 ;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
int main(){
	yyparse();
	printf("\n--- Declared identifiers and their data types ---\n");
	for (int i = 0; i < cnt; i++) {
		printf("ID %s, TYPE: %s : %s\n", symTable[i], idtype[i], dtarr[i]);
	}
	return 0;
}

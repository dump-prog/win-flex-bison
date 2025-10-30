%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex(void);
%}

/* Declare tokens */
%token DT ID NUM EQ NE GE LE IF ELSE WHILE SWITCH CASE DEFAULT BREAK FOR INCLUDE INC DEC RETURN PLUSEQ MINUSEQ
%expect 1

%%

/* Top-level program: single include followed by 0..N globals */
PROG
    : INCLUDE GLOBALS
    ;

/* 0..N global items */
GLOBALS
    : /* empty */
    | GLOBALS GLOBAL
    ;

/* Global can be a function definition, function prototype, or a top-level declaration */
GLOBAL
    : FUNC_DEF
    | FUNC_PROTO     /* <-- new: function prototype/declaration */
    | DECL
    ;

/* Function definition: return-type name ( params_opt ) block */
FUNC_DEF
    : DT ID '(' PARAMS_OPT ')' BLK
    ;

/* Function prototype (no body) */
FUNC_PROTO
    : DT ID '(' PARAMS_OPT ')' ';'
    ;

/* Optional parameter list (empty or a comma-separated list) */
PARAMS_OPT
    : /* empty */
    | PARAMLIST
    ;

/* Comma-separated parameters */
PARAMLIST
    : PARAM
    | PARAMLIST ',' PARAM
    ;

/* A parameter may be a typed identifier or just a type (e.g., 'void' or unnamed param) */
PARAM
    : DT ID
    | DT
    ;



/* Block */
BLK
    : '{' SS '}'
    ;

/* Statements list */
SS
    : SS S
    | S
    | SS error ';' { yyerror("Syntax error in statement"); yyerrok; }
    ;

/* Statements: matched / unmatched to handle dangling else */
S
    : MSTAT
    | UMSTAT
    ;

/* Matched statements: if-else fully paired, plus other statements */
MSTAT
    : X ';'                    /* expression statement */
    | RETURNST
    | BLK
    | WHILEST
    | FORST
    | SWITCHST
    | DECL
    | ';'                      /* empty statement */
    | IF '(' X ')' MSTAT ELSE MSTAT

    /* standalone update/increment/decrement statements (minimal, unambiguous) */
    | ID INC ';'               /* a++; */
    | ID DEC ';'               /* a--; */
    | INC ID ';'               /* ++a;  (rare, but allowed) */
    | DEC ID ';'               /* --a;  (rare, but allowed) */
    | ID PLUSEQ E ';'          /* a += expr; */
    | ID MINUSEQ E ';'         /* a -= expr; */
    ;


/* Unmatched statements: if without else */
UMSTAT
    : IF '(' X ')' S
    ;

/* Variable declarations */
DECL
    : DT IDLIST ';'
    | DT ID '=' E ';'
    ;

IDLIST
    : ID ',' IDLIST
    | ID
    ;

/* while statement: any statement (including unmatched) allowed */
WHILEST
    : WHILE '(' E ')' S
    ;

/* for statement: single statement or block */
FORST
    : FOR '(' INIT ';' COND ';' UPD ')' S
    | FOR error ')' BLK { yyerror("Invalid FOR syntax"); yyerrok; yyclearin; }
    ;

/* for loop parts */
INIT
    : DT X
    | X
    | /* empty */
    ;

COND
    : E
    | /* empty */
    ;

UPD
    : ID INC
    | ID DEC
    | INC ID
    | DEC ID
    | ID PLUSEQ E
    | ID MINUSEQ E
    | X
    ;

/* switch statement */
SWITCHST
    : SWITCH '(' E ')' '{' CASELIST DEFAULTOPT '}'
    ;

CASELIST
    : CASELIST CASEBLOCK
    | CASEBLOCK
    ;

CASEBLOCK
    : CASE NUM ':' SS BREAKOPT
    ;

BREAKOPT
    : BREAK ';'
    | /* empty */
    ;

DEFAULTOPT
    : DEFAULT ':' SS
    | /* empty */
    ;

/* return statements */
RETURNST
    : RETURN ';'
    | RETURN E ';'
    ;

/* Expressions */
X
    : X '=' E
    | E
    ;

E
    : E EQ T
    | E NE T
    | T
    ;

T
    : T GE P
    | T LE P
    | T '>' P
    | T '<' P
    | P
    ;

P
    : P '+' A
    | P '-' A
    | A
    ;

A
    : A '*' B
    | A '/' B
    | B
    ;

B
    : C '^' B
    | C
    ;

C
    : ID
    | NUM
    | '(' E ')'
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    if (yyparse() == 0)
        printf("Program parsed successfully.\n");
    return 0;
}

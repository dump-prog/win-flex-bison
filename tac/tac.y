%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(char *s);
extern int yylex();

int temp_count = 0;
int label_count = 0;

char* new_temp() {
    char* temp = malloc(10);
    sprintf(temp, "t%d", temp_count++);
    return temp;
}

char* new_label() {
    char* label = malloc(10);
    sprintf(label, "L%d", label_count++);
    return label;
}
%}

%union {
    char* sval;
}

%token <sval> ID NUM
%token IF ELSE WHILE
%token GE LE EQ NE GT LT
%left '+' '-'
%left '*' '/'
%type <sval> E T F B M N
%start program

%%

program:
    Stmt
    ;

Stmt:
      ID '=' E ';' {
          printf("TAC: %s = %s\n", $1, $3);
      }
    | IF '(' B ')' M Stmt N ELSE M Stmt {
          printf("TAC: goto %s\n", $7);
          printf("LABEL %s:\n", $9);
      }
    | WHILE M '(' B ')' M Stmt {
          printf("TAC: goto %s\n", $2);
          printf("LABEL %s:\n", $6);
      }
    ;

B:
      E LT E { $$ = new_label(); printf("if %s < %s goto %s\n", $1, $3, $$); }
    | E GT E { $$ = new_label(); printf("if %s > %s goto %s\n", $1, $3, $$); }
    | E GE E { $$ = new_label(); printf("if %s >= %s goto %s\n", $1, $3, $$); }
    | E LE E { $$ = new_label(); printf("if %s <= %s goto %s\n", $1, $3, $$); }
    | E EQ E { $$ = new_label(); printf("if %s == %s goto %s\n", $1, $3, $$); }
    | E NE E { $$ = new_label(); printf("if %s != %s goto %s\n", $1, $3, $$); }
    ;

E:
      E '+' T { $$ = new_temp(); printf("%s = %s + %s\n", $$, $1, $3); }
    | E '-' T { $$ = new_temp(); printf("%s = %s - %s\n", $$, $1, $3); }
    | T
    ;

T:
      T '*' F { $$ = new_temp(); printf("%s = %s * %s\n", $$, $1, $3); }
    | T '/' F { $$ = new_temp(); printf("%s = %s / %s\n", $$, $1, $3); }
    | F
    ;

F:
      '(' E ')' { $$ = $2; }
    | ID
    | NUM
    ;

M:
      /* marker label */ { $$ = new_label(); printf("LABEL %s:\n", $$); }
    ;

N:
      /* jump label */ { $$ = new_label(); printf("goto %s\n", $$); }
    ;

%%

void yyerror(char *s) {
    fprintf(stderr, "Syntax Error: %s\n", s);
}

int main() {
    printf("=== TAC Generator (Enhanced Version) ===\n");
    printf("Enter code (Ctrl+D to end):\n\n");
    yyparse();
    printf("\n=== END OF TAC ===\n");
    return 0;
}
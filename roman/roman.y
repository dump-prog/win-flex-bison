%{
#include <stdio.h>
#include <stdlib.h>

int yylex();
void yyerror(const char *s);
%}

%union {
  int val;
}

%token <val> D H T U

%%

start: roman '\n' { printf("Decimal = %d\n", $1); }
     ;

roman: D H T U    { $$ = $1 + $2 + $3 + $4; }
     | D H T      { $$ = $1 + $2 + $3; }
     | D H        { $$ = $1 + $2; }
     | H T U      { $$ = $1 + $2 + $3; }
     | H T        { $$ = $1 + $2; }
     | T U        { $$ = $1 + $2; }
     | U          { $$ = $1; }
     ;

%%

void yyerror(const char *s) {
  printf("Error: %s\n", s);
}

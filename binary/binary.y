%{
#include <stdio.h>
#include <stdlib.h>

int yylex();
void yyerror(const char *s);
%}

%union {
  int val;
}

%token <val> BIN

%%

start: binline
     ;

binline:
      BIN '\n'    { printf("Decimal = %d\n", $1); }
    | BIN          { printf("Decimal = %d\n", $1); }
    ;

%%

void yyerror(const char *s) {
  printf("Error: %s\n", s);
}

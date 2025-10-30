%{
#include <stdio.h>
int yylex();
void yyerror(const char *s) { printf("Error: %s\n", s); }
int sum = 0;
%}

%token NUMBER

%%

input:
    /* empty */
  | input NUMBER  { sum += $2; }
  ;

%%

int main() {
    yyparse();
    printf("Sum = %d\n", sum);
    return 0;
}
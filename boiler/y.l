%{
#include "y.tab.h"   // to use token names from Yacc
%}

%%

[0-9]+      { yylval = atoi(yytext); return NUMBER; }
[ \t\n]+    ;           // ignore spaces
.           ;           // ignore everything else

%%

int yywrap() { return 1; }
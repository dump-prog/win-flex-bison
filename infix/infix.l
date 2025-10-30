%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%

[ \t]+           { /* ignore spaces/tabs */ }
"\n"            { return '\n'; }
[0-9]+           {
                    /* return numeric literal as ID-style token carrying string */
                    yylval.str = strdup(yytext);
                    return ID;
                 }
[A-Za-z][A-Za-z0-9]* {
                    yylval.str = strdup(yytext);
                    return ID;
                 }
"+"            { return '+'; }
"-"            { return '-'; }
"*"            { return '*'; }
"/"            { return '/'; }
"^"            { return '^'; }
"("            { return '('; }
")"            { return ')'; }
.
                { /* ignore any other char */ }

%%

int yywrap(void) { return 1; }

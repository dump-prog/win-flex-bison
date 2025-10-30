%{
#include <stdio.h>
#include "enhanced.tab.h"
#include <string.h>
%}

ID      [a-zA-Z_][a-zA-Z0-9_]*
NUM     [0-9]+

%%
"if"                    { return IF; }
"else"                  { return ELSE; }
"while"                 { return WHILE; }
"print"                 { return PRINT; }
{NUM}                   { yylval.sval = strdup(yytext); return NUM; }
{ID}                    { yylval.sval = strdup(yytext); return ID; }
"("|")"|"{"|"}"|";"|"+"|"-"|"*"|"/"|","  { return yytext[0]; }
[ \t\r\n]+            { /* skip whitespace */ }
.                       { return yytext[0]; }
%%

int yywrap(void) { return 1; }

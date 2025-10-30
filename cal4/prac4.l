%{
#include <stdio.h>
#include "prac4.tab.h"
%}

DT      (int|char|float|double|void|string|long|short)
ID      [a-zA-Z_][a-zA-Z0-9_]*
NUM     [0-9]+

%%

"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }
"switch"        { return SWITCH; }
"case"          { return CASE; }
"default"       { return DEFAULT; }
"break"         { return BREAK; }
"return"        { return RETURN; }

"++"             { return INC; }
"--"             { return DEC; }
"=="             { return EQ; }
"!="             { return NE; }
">="             { return GE; }
"<="             { return LE; }
"\+="            { return PLUSEQ; }
"-="             { return MINUSEQ; }

{DT}             { return DT; }
{NUM}            { yylval = atoi(yytext); return NUM; } /* optional: set yylval if needed */
{ID}             { return ID; }

"#include"<[a-zA-Z0-9./_]+>    { return INCLUDE; }

[ \t\n]+         { /* skip whitespace */ }
[+\-*/^><=;(){}:,]   { return yytext[0]; }
.                { /* ignore unknown char */ }

%%

int yywrap(void) {
    return 1;
}

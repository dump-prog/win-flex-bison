%{
#include <stdio.h>
#include "pract9.tab.h"
%}

/* Regular definitions */
DT      (int|char|float|double|void|string|long|short)
ID      [a-zA-Z_][a-zA-Z0-9_]*
NUM     [0-9]+

%%
"if"                    { return IF; }
"else"                  { return ELSE; }
"while"                 { return WHILE; }
"for"                   { return FOR; }
"++"                    { return INC; }
"--"                    { return DEC; }
"switch"                { return SWITCH; }
"case"                  { return CASE; }
"default"               { return DEFAULT; }
"break"                 { return BREAK; }
{DT}                    { return DT; }
{NUM}                   { yylval.ival=atoi(yytext); return NUM; }
{ID}                    { yylval.id=strdup(yytext);return ID; }
"=="                    { return EQ; }
"!="                    { return NE; }
">="                    { return GE; }
"<="                    { return LE; }
\n                      {}
[ \t]+                  {}
[+\-*/^><=;:(){},]         { return yytext[0]; }
.                       {}
%%

int yywrap() {
    return 1;
}

%{
#include <stdio.h>
#include "pract6.tab.h"
#include <string.h>
char symTable[100][8];
int cnt=0;
int symLookup(char *idname);
char currentDT[50];
extern char dtarr[100][50];
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
{DT}                    { strcpy(currentDT, yytext); return DT; }
{NUM}                   { return NUM; }
{ID}                    { yylval=symLookup(yytext); return ID; }
"=="                    { return EQ; }
"!="                    { return NE; }
">="                    { return GE; }
"<="                    { return LE; }
\n                      {}
[ \t]+                  {}
[+\-*/^><=;:(){},]      { return yytext[0]; }
.                       { }
%%
int symLookup(char *s) {
    for (int i = 0; i < cnt; i++) {
        if (strcmp(symTable[i], s) == 0) return i;  // already exists
    }
    strcpy(symTable[cnt], s);   // add new symbol
    return cnt++;
}
int idExists(int index) {
    return dtarr[index][0] != '\0';
}
int yywrap() {
    return 1;
}

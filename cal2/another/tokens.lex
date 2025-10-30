%{
#include <stdio.h>
int line_no = 1;
%}
%option noyywrap

%%

"//".* {  }
\/\*([^*]|\*+[^/])*\*+\/ {  }

^#.* {  }

[-+]?[0-9]?"."[0-9]{1,6} { printf("FNUM "); }
[-+]?[0-9]+ { printf("NUM "); }
\".*\" { printf("STR "); }
\'.\' { printf("CHAR "); }

"int"|"float"|"char"|"bool"|"void" { printf("DT "); }
"if"|"for"|"while"|"break"|"main"|"return" { printf("%s KEYWORD\n", yytext); }

([a-zA-Z_][a-zA-Z0-9_]*) { printf("ID "); }

"+"|"-"|"*"|"/"|"%" { printf("OP "); }

[=] { printf("= "); }
[\{\}\(\);,\[\]] { printf("%s ", yytext); }

[\n] { line_no++; printf("\n"); }
[ \t]+ { /* ignore whitespace */ }

. { printf("%s is Lexical Error at %d\n", yytext,line_no); }

%%

int main(void) {
    yylex();
    return 0;
}

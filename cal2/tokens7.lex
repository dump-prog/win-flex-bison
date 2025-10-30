%{
#include <stdio.h>
int line_no = 1;
%}
%option noyywrap

%%



"//".* {  }
\/\*([^*]|\*+[^/])*\*+\/ {  }

^#.* { printf("Preprocessor Directive: %s\n", yytext); }

[+-]?[0-9]+ { printf("%s is SIGNED INTEGER CONSTANT\n", yytext); }
[+-]?[.][0-9]{1,6} { printf("%s is FLOAT CONSTANT\n", yytext); }
\".*\" { printf("%s is STRING CONSTANT\n", yytext); }
\'.\' { printf("%s is CHARACTER CONSTANT\n", yytext); }

"int"|"float"|"char"|"bool"|"void" { printf("%s is DATA TYPE\n", yytext); }
"if"|"for"|"while"|"break"|"main"|"return" { printf("%s is KEYWORD\n", yytext); }

([a-zA-Z_][a-zA-Z0-9_]*) { printf("Identifier: %s\n", yytext); }

"+"|"-"|"*"|"/"|"%" { printf("%s is ARITHMETIC OPERATOR\n", yytext); }

[\{\}\(\);,=\[\]] { printf("%s is SPECIAL SYMBOL\n", yytext); }

[\n] { line_no++; }
[ \t]+ { /* ignore whitespace */ }

. { printf("%s is Lexical Error at %d\n", yytext,line_no); }

%%

int main(void) {
    yylex();
    return 0;
}

%{ 
#include <stdio.h> 
%} 
 
%% 
 
[0-9]+                     { printf("%s is NUM\n", yytext); } 
"int"|"return"             { printf("%s is keyword\n", yytext); } 
[a-zA-Z_][a-zA-Z0-9_]*     { printf("%s is identifier\n", yytext); } 
[ \t\n]+                   { /* Ignore whitespace */ } 
.                          { printf("%s is invalid token\n", yytext); } 
 
%% 

int yywrap() {}
int main(void) 
{ 
    yylex(); 
    return 0; 
} 
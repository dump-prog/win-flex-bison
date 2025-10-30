%{
#include <stdio.h>
#include <string.h>

int line_no = 1;
char identifiers[1000][100]; // identifier table
int id_count = 0;

void add_identifier(const char* id);
%}

%option noyywrap

%%

"//".*                      { /* Ignore single-line comments */ }
\/\*([^*]|\*+[^/])*\*+\/    { /* Ignore multi-line comments */ }

^#.*                        { printf("Preprocessor Directive: %s\n", yytext); }

[-+]?[0-9]?"."[0-9]{1,6}    { printf("FNUM "); }
[-+]?[0-9]+                 { printf("NUM "); }
\".*\"                      { printf("STR "); }
\'.\'                       { printf("CHAR "); }

"int"|"float"|"char"|"bool"|"void"  { printf("DT "); }
"if"|"for"|"while"|"break"|"main"|"return" { printf("%s KEYWORD\n", yytext); }

([a-zA-Z_][a-zA-Z0-9_]*)    {
    printf("ID ");
    add_identifier(yytext); // << calling the UDF
}

"+"|"-"|"*"|"/"|"%"         { printf("OP "); }

[=]                         { printf("= "); }
[\{\}\(\);,\[\]]            { printf("%s ", yytext); }

\n                          { line_no++; printf("\n"); }
[ \t]+                      { /* Ignore whitespace */ }

.                           { printf("%s is Lexical Error at line %d\n", yytext, line_no); }

%%

void add_identifier(const char* id) {
    for (int i = 0; i < id_count; i++) {
        if (strcmp(identifiers[i], id) == 0) {
            return; // already present
        }
    }
    strcpy(identifiers[id_count], id);
    id_count++;
}

int main(void) {
    printf("Tokens:\n");
    yylex();

    printf("\n\nUnique Identifiers:\n");
    for (int i = 0; i < id_count; i++) {
        printf("%s\n", identifiers[i]);
    }

    return 0;
}

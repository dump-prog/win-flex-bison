%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

/* helper: build postfix string "left right op" and free operands */
char *make_op(char *l, char *r, const char *op) {
    size_t len = strlen(l) + 1 + strlen(r) + 1 + strlen(op) + 1;
    char *res = malloc(len + 1);
    if (!res) { fprintf(stderr, "out of memory\n"); exit(1); }
    snprintf(res, len + 1, "%s %s %s", l, r, op);
    free(l); free(r);
    return res;
}

/* For unary minus support (optional) */
char *make_unary(char *v, const char *op) {
    size_t len = strlen(v) + 1 + strlen(op) + 1;
    char *res = malloc(len + 1);
    if (!res) { fprintf(stderr, "out of memory\n"); exit(1); }
    snprintf(res, len + 1, "%s %s", v, op);
    free(v);
    return res;
}

%}

%union { char *str; }

%token <str> ID

%left '+' '-'
%left '*' '/'
%right '^'

%%

input:
      /* empty */
    | input line
    ;

line:
      '\n'
    | expr '\n' { printf("Postfix: %s\n", $1); free($1); }
    ;

expr:
      expr '+' term { $$ = make_op($1, $3, "+"); }
    | expr '-' term { $$ = make_op($1, $3, "-"); }
    | term          { $$ = $1; }
    ;

term:
      term '*' factor { $$ = make_op($1, $3, "*"); }
    | term '/' factor { $$ = make_op($1, $3, "/"); }
    | factor          { $$ = $1; }
    ;

factor:
      '(' expr ')' { $$ = $2; }
    | ID           { $$ = $1; } /* ID already strdup'd by lexer */
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

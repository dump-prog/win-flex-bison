%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
extern int yylex();

#define MAX_REGS 8

typedef struct {
    char *var;
    char reg[8];
    unsigned long last_used;
    int occupied;
} RegEntry;

RegEntry regfile[MAX_REGS];
unsigned long timecounter = 1;

char* new_temp() {
    static int cnt = 0;
    char *t = malloc(16);
    sprintf(t, "t%d", cnt++);
    return t;
}

char* new_label() {
    static int cnt = 0;
    char *l = malloc(16);
    sprintf(l, "L%d", cnt++);
    return l;
}

char* getreg(char* var) {
    if (!var) return NULL;
    for (int i = 0; i < MAX_REGS; i++) {
        if (regfile[i].occupied && strcmp(regfile[i].var, var) == 0) {
            regfile[i].last_used = ++timecounter;
            return regfile[i].reg;
        }
    }
    for (int i = 0; i < MAX_REGS; i++) {
        if (!regfile[i].occupied) {
            regfile[i].var = strdup(var);
            sprintf(regfile[i].reg, "R%d", i);
            regfile[i].occupied = 1;
            regfile[i].last_used = ++timecounter;
            return regfile[i].reg;
        }
    }
    /* spill LRU */
    unsigned long oldest = regfile[0].last_used;
    int idx = 0;
    for (int i = 1; i < MAX_REGS; i++) if (regfile[i].last_used < oldest) { oldest = regfile[i].last_used; idx = i; }
    printf("// [SPILL] reusing %s (%s) for %s\n", regfile[idx].var, regfile[idx].reg, var);
    free(regfile[idx].var);
    regfile[idx].var = strdup(var);
    regfile[idx].last_used = ++timecounter;
    return regfile[idx].reg;
}

void print_regfile() {
    printf("\n==== Register Table ====");
    for (int i = 0; i < MAX_REGS; i++) {
        if (regfile[i].occupied) printf("\n%s -> %s", regfile[i].var, regfile[i].reg);
    }
    printf("\n\n");
}

%}

%union { char* sval; }

%token <sval> ID NUM IF ELSE WHILE PRINT
%left '+' '-'
%left '*' '/'

%type <sval> E

%%

program:
    stmt_list
    ;

stmt_list:
      stmt_list stmt
    | stmt
    ;

stmt:
      ID '=' E ';' {
          char *rd = getreg($1);
          char *rs = getreg($3);
          if (rs && rd) printf("    MOV %s, %s\n", rd, rs);
          else if (rd && $3) printf("    MOV %s, %s\n", rd, $3);
      }
    | PRINT '(' ID ')' ';' {
          char *r = getreg($3);
          printf("    OUT %s\n", r);
      }
    | IF '(' E ')' stmt {
          /* simplified: E yields a temp/var name in $3 */
          char *lbl = new_label();
          printf("    CMP %s, 0\n", $3);
          printf("    JE %s\n", lbl);
          /* then stmt */
          printf("%s:\n", lbl);
      }
    | WHILE '(' E ')' stmt {
          char *start = new_label();
          char *end = new_label();
          printf("%s:\n", start);
          printf("    CMP %s, 0\n", $3);
          printf("    JE %s\n", end);
          /* body */
          printf("    JMP %s\n", start);
          printf("%s:\n", end);
      }
    | '{' stmt_list '}'
    ;

E:
      E '+' E { char *t = new_temp(); printf("    ADD %s, %s\n", getreg($1), getreg($3)); $$ = t; }
    | E '-' E { char *t = new_temp(); printf("    SUB %s, %s\n", getreg($1), getreg($3)); $$ = t; }
    | E '*' E { char *t = new_temp(); printf("    MUL %s, %s\n", getreg($1), getreg($3)); $$ = t; }
    | E '/' E { char *t = new_temp(); printf("    DIV %s, %s\n", getreg($1), getreg($3)); $$ = t; }
    | '(' E ')' { $$ = $2; }
    | ID { $$ = $1; }
    | NUM { $$ = $1; }
    ;

%%

void yyerror(const char *s) { fprintf(stderr, "Parse error: %s\n", s); }

int main() {
    printf("\n==== Enhanced p9 TAC with LRU Allocation ====\n\n");
    yyparse();
    print_regfile();
    return 0;
}

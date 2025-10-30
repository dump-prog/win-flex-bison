%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(char *s);
extern int yylex();

#define MAX_REGS 8
#define MAX_VARS 100

// --- Register Allocation Table ---
typedef struct {
    char var[32];
    char reg[8];
} RegEntry;

RegEntry reg_table[MAX_VARS];
int reg_count = 0;
int next_reg = 0;

int temp_count = 0, label_count = 0;

// --- Function to allocate new temporary ---
char* new_temp() {
    char* t = malloc(10);
    sprintf(t, "t%d", temp_count++);
    return t;
}

// --- Function to allocate new label ---
char* new_label() {
    char* l = malloc(10);
    sprintf(l, "L%d", label_count++);
    return l;
}

// --- Simple getreg(): assigns registers to variables ---
char* getreg(char* var) {
    // check if already assigned
    for (int i = 0; i < reg_count; i++) {
        if (strcmp(reg_table[i].var, var) == 0)
            return reg_table[i].reg;
    }

    // assign new register
    if (next_reg >= MAX_REGS) {
        printf("// [WARNING] Register spill for %s, reusing registers!\n", var);
        next_reg = 0; // start reusing (naive)
    }

    sprintf(reg_table[reg_count].var, "%s", var);
    sprintf(reg_table[reg_count].reg, "R%d", next_reg++);
    reg_count++;

    return reg_table[reg_count - 1].reg;
}

%}

%union {
    char* sval;
}

%token <sval> ID NUM
%token IF ELSE WHILE PRINT
%token GE LE EQ NE GT LT
%left '+' '-'
%left '*' '/'
%type <sval> E T F B M N
%start program

%%

program:
    stmt_list
    ;

stmt_list:
      stmt_list Stmt
    | Stmt
    ;

Stmt:
      ID '=' E ';' {
          char* rdest = getreg($1);
          char* rsrc  = getreg($3);
          printf("    MOV %s, %s\n", rdest, rsrc);
      }
    | PRINT '(' ID ')' ';' {
          char* r = getreg($3);
          printf("    OUT %s\n", r);
      }
    | IF '(' B ')' M Stmt N ELSE M Stmt {
          printf("    JMP %s\n", $7);
          printf("%s:\n", $9);
      }
    | WHILE M '(' B ')' M Stmt {
          printf("    JMP %s\n", $2);
          printf("%s:\n", $6);
      }
    | '{' stmt_list '}'
    ;

B:
      E LT E { $$ = new_temp(); printf("    CMP %s, %s\n", getreg($1), getreg($3)); printf("    JL %s\n", $$); }
    | E GT E { $$ = new_temp(); printf("    CMP %s, %s\n", getreg($1), getreg($3)); printf("    JG %s\n", $$); }
    | E GE E { $$ = new_temp(); printf("    CMP %s, %s\n", getreg($1), getreg($3)); printf("    JGE %s\n", $$); }
    | E LE E { $$ = new_temp(); printf("    CMP %s, %s\n", getreg($1), getreg($3)); printf("    JLE %s\n", $$); }
    | E EQ E { $$ = new_temp(); printf("    CMP %s, %s\n", getreg($1), getreg($3)); printf("    JE %s\n", $$); }
    | E NE E { $$ = new_temp(); printf("    CMP %s, %s\n", getreg($1), getreg($3)); printf("    JNE %s\n", $$); }
    ;

E:
      E '+' T { $$ = new_temp(); printf("    ADD %s, %s\n", getreg($1), getreg($3)); }
    | E '-' T { $$ = new_temp(); printf("    SUB %s, %s\n", getreg($1), getreg($3)); }
    | T
    ;

T:
      T '*' F { $$ = new_temp(); printf("    MUL %s, %s\n", getreg($1), getreg($3)); }
    | T '/' F { $$ = new_temp(); printf("    DIV %s, %s\n", getreg($1), getreg($3)); }
    | F
    ;

F:
      '(' E ')' { $$ = $2; }
    | ID        { $$ = $1; }
    | NUM       { $$ = $1; }
    ;

M:
      { $$ = new_label(); printf("%s:\n", $$); }
    ;

N:
      { $$ = new_label(); printf("    JMP %s\n", $$); }
    ;

%%

void yyerror(char *s) {
    fprintf(stderr, "Syntax Error: %s\n", s);
}

int main() {
    printf("\n==== TAC with Register Allocation ====\n");
    printf("Enter code (Ctrl+D to end):\n\n");
    yyparse();

    printf("\n==== Register Table ====\n");
    for (int i = 0; i < reg_count; i++)
        printf("%s → %s\n", reg_table[i].var, reg_table[i].reg);

    printf("\n==== END ====\n");
    return 0;
}

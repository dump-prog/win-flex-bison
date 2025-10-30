%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);

#define MAX_VARS 200
#define MAX_REGS 8

typedef struct {
    char* name;
    int isConst;
    int val;
} symtab_entry;

symtab_entry symtab[MAX_VARS];
int symtab_size = 0;

typedef struct ex {
    int isConst;
    int val;
    char* name; /* variable or temporary name */
} ex;

/* --- Register allocation structures (simple LRU spill) --- */
typedef struct {
    char *var;      /* variable name stored in this register */
    char regname[8];
    unsigned long last_used; /* timestamp to implement LRU */
    int occupied;
} RegEntry;

RegEntry regfile[MAX_REGS];
unsigned long timecounter = 1;

symtab_entry* getVar(const char* name) {
    for (int i = 0; i < symtab_size; i++)
        if (strcmp(symtab[i].name, name) == 0)
            return &symtab[i];

    if (symtab_size >= MAX_VARS) {
        fprintf(stderr, "Symbol table overflow!\n");
        exit(1);
    }

    symtab[symtab_size].name = strdup(name);
    symtab[symtab_size].isConst = 0;
    symtab[symtab_size].val = 0;
    symtab_size++;
    return &symtab[symtab_size - 1];
}

char* new_temp() {
    static int temp_count = 0;
    char *t = malloc(16);
    sprintf(t, "t%d", temp_count++);
    return t;
}

char* new_label() {
    static int label_count = 0;
    char *l = malloc(16);
    sprintf(l, "L%d", label_count++);
    return l;
}

/* getreg: return register name for variable; allocate or spill using LRU */
char* getreg(char* var) {
    if (!var) return NULL;
    /* if var already in regfile, update timestamp and return */
    for (int i = 0; i < MAX_REGS; i++) {
        if (regfile[i].occupied && strcmp(regfile[i].var, var) == 0) {
            regfile[i].last_used = ++timecounter;
            return regfile[i].regname;
        }
    }

    /* find free register */
    for (int i = 0; i < MAX_REGS; i++) {
        if (!regfile[i].occupied) {
            regfile[i].var = strdup(var);
            sprintf(regfile[i].regname, "R%d", i);
            regfile[i].occupied = 1;
            regfile[i].last_used = ++timecounter;
            return regfile[i].regname;
        }
    }

    /* no free register: pick LRU (smallest last_used) to spill */
    unsigned long oldest = regfile[0].last_used;
    int oldest_i = 0;
    for (int i = 1; i < MAX_REGS; i++) {
        if (regfile[i].last_used < oldest) {
            oldest = regfile[i].last_used;
            oldest_i = i;
        }
    }

    /* spill: write comment and reuse reg */
    printf("// [SPILL] spilling %s from %s to make room for %s\n", regfile[oldest_i].var, regfile[oldest_i].regname, var);
    free(regfile[oldest_i].var);
    regfile[oldest_i].var = strdup(var);
    regfile[oldest_i].last_used = ++timecounter;
    return regfile[oldest_i].regname;
}

/* helper to print register table at end */
void print_reg_table() {
    printf("\n==== Register Table ====%s\n", "");
    for (int i = 0; i < MAX_REGS; i++) {
        if (regfile[i].occupied) printf("%s -> R%d\n", regfile[i].var, i);
    }
    printf("\n");
}

%}

%union {
    int ival;
    char* id;
    struct ex* expr;
}

%token DT EQ NE GE LE IF ELSE WHILE FOR INC DEC SWITCH CASE DEFAULT BREAK
%token <id> ID
%token <ival> NUM
%type <expr> E T P A B C X

%%

PROG: DT ID '(' ')' BLK ;

BLK: '{' SS '}'
   | '{' '}'
   ;

SS: SS S
  | S
  ;

S: X ';'
 | DECL
 | IFST
 | WHILEST
 | FORST
 | SWITCHST
 | BLK
 ;

DECL: DT IDLIST ';' ;

IDLIST: ID 
      {
        getVar($1);
      }
      | ID '=' E
      {
        symtab_entry* var = getVar($1);
        if ($3->isConst) {
            var->isConst = 1;
            var->val = $3->val;
            printf("%s = %d\n", $1, $3->val);
        } else {
            var->isConst = 0;
            if ($3->name) {
                printf("%s = %s\n", $1, $3->name);
            }
        }
      }
      | IDLIST ',' ID
      {
        getVar($3);
      }
      | IDLIST ',' ID '=' E 
      {
        symtab_entry* var = getVar($3);
        if ($5->isConst) {
            var->isConst = 1;
            var->val = $5->val;
            printf("%s = %d\n", $3, $5->val);
        } else {
            var->isConst = 0;
            if ($5->name) {
                printf("%s = %s\n", $3, $5->name);
            }
        }
      }
      ;

IFST: IF '(' X ')' BLK
    | IF '(' X ')' BLK ELSE BLK
    ;

WHILEST: WHILE '(' X ')' BLK ;

FORST: FOR '(' INIT ';' COND ';' STEP ')' BLK ;
INIT: DT ID '=' E
    | X
    | /* empty */
    ;
COND: E
    | /* empty */
    ;
STEP: E
    | /* empty */
    ;

SWITCHST: SWITCH '(' E ')' '{' CASELIST DEFAULTOPT '}'
        ;
CASELIST: CASELIST CASEBLOCK
        | CASEBLOCK
        ;
CASEBLOCK: CASE NUM ':' SS BREAKOPT ;
BREAKOPT: BREAK ';'
         | /* empty */
         ;
DEFAULTOPT: DEFAULT ':' SS
          | /* empty */
          ;

X: ID '=' E
{
    symtab_entry* var = getVar($1);
    if ($3->isConst) {
        var->isConst = 1;
        var->val = $3->val;
    } else {
        var->isConst = 0;
    }
    if ($3->isConst) {
        printf("%s = %d\n", $1, $3->val);
    } else if ($3->name) {
        printf("%s = %s\n", $1, $3->name);
    }
    $$ = $3;
}
;

E: E EQ T
{
    $$ = (ex*)malloc(sizeof(ex));
    if ($1->isConst && $3->isConst) { 
        $$->isConst = 1; 
        $$->val = ($1->val == $3->val); 
        $$->name = NULL; 
    } else { 
        $$->isConst = 0; 
        $$->name = NULL; 
    }
}
| E NE T
{
    $$ = (ex*)malloc(sizeof(ex));
    if ($1->isConst && $3->isConst) { 
        $$->isConst = 1; 
        $$->val = ($1->val != $3->val); 
        $$->name = NULL; 
    } else { 
        $$->isConst = 0; 
        $$->name = NULL; 
    }
}
| T { $$ = $1; }
;

T: T '>' P
{
    $$ = (ex*)malloc(sizeof(ex));
    if ($1->isConst && $3->isConst) { 
        $$->isConst = 1; 
        $$->val = ($1->val > $3->val); 
        $$->name = NULL; 
    } else { 
        $$->isConst = 0; 
        $$->name = NULL; 
    }
}
| T '<' P
{
    $$ = (ex*)malloc(sizeof(ex));
    if ($1->isConst && $3->isConst) { 
        $$->isConst = 1; 
        $$->val = ($1->val < $3->val); 
        $$->name = NULL; 
    } else { 
        $$->isConst = 0; 
        $$->name = NULL; 
    }
}
| T GE P
{
    $$ = (ex*)malloc(sizeof(ex));
    if ($1->isConst && $3->isConst) { 
        $$->isConst = 1; 
        $$->val = ($1->val >= $3->val); 
        $$->name = NULL; 
    } else { 
        $$->isConst = 0; 
        $$->name = NULL; 
    }
}
| T LE P
{
    $$ = (ex*)malloc(sizeof(ex));
    if ($1->isConst && $3->isConst) { 
        $$->isConst = 1; 
        $$->val = ($1->val <= $3->val); 
        $$->name = NULL; 
    } else { 
        $$->isConst = 0; 
        $$->name = NULL; 
    }
}
| P { $$ = $1; }
;

P: P '+' A
{
    $$ = (ex*)malloc(sizeof(ex));
    if ($1->isConst && $3->isConst) { 
        $$->isConst = 1; 
        $$->val = $1->val + $3->val; 
        $$->name = NULL; 
    } else { 
        $$->isConst = 0; 
        $$->name = NULL; 
    }
}
| P '-' A
{
    $$ = (ex*)malloc(sizeof(ex));
    if ($1->isConst && $3->isConst) { 
        $$->isConst = 1; 
        $$->val = $1->val - $3->val; 
        $$->name = NULL; 
    } else { 
        $$->isConst = 0; 
        $$->name = NULL; 
    }
}
| A { $$ = $1; }
;

A: A '*' B
{
    $$ = (ex*)malloc(sizeof(ex));
    if ($1->isConst && $3->isConst) { 
        $$->isConst = 1; 
        $$->val = $1->val * $3->val; 
        $$->name = NULL; 
    } else { 
        $$->isConst = 0; 
        $$->name = NULL; 
    }
}
| A '/' B
{
    $$ = (ex*)malloc(sizeof(ex));
    if ($1->isConst && $3->isConst && $3->val != 0) { 
        $$->isConst = 1; 
        $$->val = $1->val / $3->val; 
        $$->name = NULL; 
    } else { 
        $$->isConst = 0; 
        $$->name = NULL; 
    }
}
| B { $$ = $1; }
;

B: C '^' B
{
    $$ = (ex*)malloc(sizeof(ex));
    if ($1->isConst && $3->isConst) { 
        $$->isConst = 1; 
        int res = 1; 
        for(int i=0;i<$3->val;i++) res *= $1->val; 
        $$->val = res; 
        $$->name = NULL;
    } else { 
        $$->isConst = 0; 
        $$->name = NULL; 
    }
}
| C { $$ = $1; }
;

C: NUM 
{ 
    $$ = (ex*)malloc(sizeof(ex));
    $$->isConst = 1; 
    $$->val = $1; 
    $$->name = NULL; 
}
| ID
{
    $$ = (ex*)malloc(sizeof(ex));
    symtab_entry* var = getVar($1);
    if (var->isConst) {
        $$->isConst = 1; 
        $$->val = var->val; 
        $$->name = NULL;
    } else {
        $$->isConst = 0; 
        $$->name = strdup($1);
    }
}
| '(' E ')' { $$ = $2; }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    yyparse();
    return 0;
}
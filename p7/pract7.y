%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylineno;
int first_error_line = -1;
void yyerror(const char *s);
struct Node{
    char name[10];
    char code[1000];
};
char current_type[32];
int cnt=1;
char* newtemp();
char* concat(const char* s1, const char* s2);
char* newlabel();
int label_count=0;
int temp_count=0;
struct Node;
typedef struct Node Node;
typedef struct { char var[20]; char temp[10]; } VarMap;
VarMap var_table[100];
int var_count = 0;
char* lookup_temp(char* var);
void add_var_temp(char* var, char* temp);
%}

%union {
    struct Node* node;
    char* id;
    int ival;
}

/* Declare tokens */
%token <id> DT ID
%token EQ NE GE LE IF ELSE WHILE FOR INC DEC SWITCH CASE DEFAULT BREAK
%token <ival> NUM

%type <node> PROG BLK SS S DECL IFST WHILEST FORST IDLIST INIT COND STEP X E T P A B C
%%
PROG : DT ID '(' ')' BLK {
          $$ = malloc(sizeof(Node));
          
          sprintf($$->code, "function %s:\n%s\nend function\n", $2, $5->code);
          
          strcpy($$->name, newtemp() );
          
          printf("%s", $$->code);
          FILE *out = fopen("output.txt", "w");
          if (out) {
              fprintf(out, "%s", $$->code);
              fclose(out);
          } else {
              fprintf(stderr, "Error: Could not open output file 'output.txt'\n");
          }
      }
    | error BLK {
          yyerror("Illegal main function definition!");
          yyerrok;
          $$ = malloc(sizeof(Node));
          strcpy($$->name, "error_prog");
          strcpy($$->code, $2->code);
      }
    ;


BLK
  : '{' SS '}' {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());

        // Propagate code from statement sequence
        sprintf($$->code, "%s", $2->code);
    }
  | '{' '}' {
        $$ = malloc(sizeof(Node));

        strcpy($$->name, newtemp());
        strcpy($$->code, "");
    }
  | '{' SS {
        yyerror("Missing } in block!");
        yyerrok;

        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s", $2->code);
    }
  | error '}' {
        yyerror("Missing { in block!");
        yyerrok;

        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        strcpy($$->code, "");
    }
  ;

SS
  : SS S {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s%s", $1->code, $2->code);
    }
  | S {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s", $1->code);
    }
  ;


S
  : X ';' {
        $$ = malloc(sizeof(Node));

        // X already contains generated code for the expression/assignment
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s", $1->code);
    }
  | DECL {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s", $1->code);
    }
  | IFST {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s", $1->code);
    }
  | WHILEST {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s", $1->code);
    }
  | FORST {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s", $1->code);
    }
  | BLK {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s", $1->code);
    }
  | error ';' {
        yyerror("Invalid statement!");
        yyerrok;

        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        strcpy($$->code, "");
    }
  ;


DECL
  : DT IDLIST ';' {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, "");
        strcpy(current_type, $1);
        sprintf($$->code, "%s",$2->code);
    }
  | DT error ';' {
        yyerror("Invalid declaration syntax!");
        yyerrok;

        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        strcpy($$->code, "");
    }
  ;
IDLIST
  : ID {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        add_var_temp($1, $$->name);
        sprintf($$->code, "%s = %s\n", $$->name, $1);
    }
  | ID '=' E {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        add_var_temp($1, $$->name);
        sprintf($$->code, "%s%s = %s\n", $3->code, $$->name, $3->name);
    }
  | IDLIST ',' ID {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        add_var_temp($3, $$->name);
        sprintf($$->code, "%s%s = %s\n", $1->code, $$->name, $3);
    }
  | IDLIST ',' ID '=' E {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        add_var_temp($3, $$->name);
        sprintf($$->code, "%s%s%s = %s\n", $1->code, $5->code, $$->name, $5->name);
    }
  | IDLIST ',' error {
        yyerror("Invalid identifier in declaration list!");
        yyerrok;

        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        strcpy($$->code, $1->code);
    }
;


IFST
  : IF '(' X ')' BLK {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());

        char *L1 = newlabel();
        char *L2 = newlabel();

        sprintf($$->code,
            "%sif %s goto %s\n"
            "goto %s\n"
            "%s:\n"
            "%s"
            "%s:\n",
            $3->code, $3->name, L1, L2, L1, $5->code, L2);
    }

  | IF '(' X ')' BLK ELSE BLK {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());

        char *L1 = newlabel();  // true branch
        char *L2 = newlabel();  // false branch
        char *L3 = newlabel();  // exit label

        sprintf($$->code,
            "%sif %s goto %s\n"
            "goto %s\n"
            "%s:\n"
            "%s"
            "goto %s\n"
            "%s:\n"
            "%s"
            "%s:\n",
            $3->code, $3->name, L1, L2,
            L1, $5->code, L3,
            L2, $7->code,
            L3);
    }

  | IF error X ')' BLK {
        yyerror("Opening parenthesis missing in IF statement!");
        yyerrok;
        $$ = malloc(sizeof(Node)); strcpy($$->name, newtemp()); strcpy($$->code, $5->code);
    }
  | IF '(' error X BLK {
        yyerror("Closing parenthesis missing in IF statement!");
        yyerrok;
        $$ = malloc(sizeof(Node)); strcpy($$->name, newtemp()); strcpy($$->code, $5->code);
    }
  | IF '(' X ')' error {
        yyerror("Missing block after IF condition!");
        yyerrok;
        $$ = malloc(sizeof(Node)); strcpy($$->name, newtemp()); strcpy($$->code, "");
    }
  ;
WHILEST
  : WHILE '(' X ')' BLK {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());

        char *L1 = newlabel();
        char *L2 = newlabel();
        char *L3 = newlabel();

        sprintf($$->code,
            "%s:\n"
            "%sif %s goto %s\n"
            "goto %s\n"
            "%s:\n"
            "%s"
            "goto %s\n"
            "%s:\n",
            L1, $3->code, $3->name, L2, L3, L2, $5->code, L1, L3);
    }

  | WHILE error X ')' BLK {
        yyerror("Missing '(' in WHILE condition!");
        yyerrok;
        $$ = malloc(sizeof(Node)); strcpy($$->name, newtemp()); strcpy($$->code, $5->code);
    }
  | WHILE '(' X error BLK {
        yyerror("Missing ')' in WHILE condition!");
        yyerrok;
        $$ = malloc(sizeof(Node)); strcpy($$->name, newtemp()); strcpy($$->code, $5->code);
    }
  | WHILE '(' X ')' error {
        yyerror("Missing block after WHILE condition!");
        yyerrok;
        $$ = malloc(sizeof(Node)); strcpy($$->name, newtemp()); strcpy($$->code, "");
    }
  ;
FORST
  : FOR '(' INIT ';' COND ';' STEP ')' BLK {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());

        char *L1 = newlabel();
        char *L2 = newlabel();
        char *L3 = newlabel();

        sprintf($$->code,
            "%s" 
            "%s:\n"
            "%sif %s goto %s\n"
            "goto %s\n"
            "%s:\n"
            "%s"
            "%s"
            "goto %s\n"
            "%s:\n",
            $3->code,
            L1,
            $5->code, $5->name, L2,
            L3,
            L2,
            $9->code,
            $7->code,
            L1,
            L3);
    }

  | FOR error INIT ';' COND ';' STEP ')' BLK {
        yyerror("Missing '(' in FOR statement!");
        yyerrok;
        $$ = malloc(sizeof(Node)); strcpy($$->name, newtemp()); strcpy($$->code, $9->code);
    }
  | FOR '(' INIT ';' COND ';' STEP error BLK {
        yyerror("Missing ')' in FOR statement!");
        yyerrok;
        $$ = malloc(sizeof(Node)); strcpy($$->name, newtemp()); strcpy($$->code, $9->code);
    }
  | FOR '(' error ')' BLK {
        yyerror("Invalid FOR loop initialization or condition!");
        yyerrok;
        $$ = malloc(sizeof(Node)); strcpy($$->name, newtemp()); strcpy($$->code, $5->code);
    }
  ;
INIT
  : DT ID '=' E {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, $2);
        add_var_temp($2,$$->name);
        sprintf($$->code, "%s%s = %s\n", $4->code, $2, $4->name);
    }
  | X { $$ = $1; }
  | /* empty */ {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        strcpy($$->code, "");
    }
  ;

COND
  : E { $$ = $1; }
  | /* empty */ {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        strcpy($$->code, "");
    }
  ;

STEP
  : E { $$ = $1; }
  | /* empty */ {
        $$ = malloc(sizeof(Node));
        strcpy($$->name, newtemp());
        strcpy($$->code, "");
    }
  ;

X
  : X '=' E {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, $1->name);  // assigned variable
        sprintf($$->code, "%s%s = %s\n", $3->code, $1->name, $3->name);
    }
  | E { $$ = $1; }
;
E
  : E EQ T {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s%s = %s == %s\n", $1->code, $$->name, $1->name, $3->name);
    }
  | E NE T {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s%s = %s != %s\n", $1->code, $$->name, $1->name, $3->name);
    }
  | T { $$ = $1; }
;
T
  : T GE P {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s%s = %s >= %s\n", $1->code, $$->name, $1->name, $3->name);
    }
  | T LE P {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s%s = %s <= %s\n", $1->code, $$->name, $1->name, $3->name);
    }
  | T '>' P {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s%s = %s > %s\n", $1->code, $$->name, $1->name, $3->name);
    }
  | T '<' P {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s%s = %s < %s\n", $1->code, $$->name, $1->name, $3->name);
    }
  | P { $$ = $1; }
;
P
  : P '+' A {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s%s = %s + %s\n", $1->code, $$->name, $1->name, $3->name);
    }
  | P '-' A {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s%s = %s - %s\n", $1->code, $$->name, $1->name, $3->name);
    }
  | A { $$ = $1; }
;

A
  : A '*' B {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s%s = %s * %s\n", $1->code, $$->name, $1->name, $3->name);
    }
  | A '/' B {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s%s = %s / %s\n", $1->code, $$->name, $1->name, $3->name);
    }
  | B { $$ = $1; }
;
B
  : C '^' B {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s%s = %s ^ %s\n", $1->code, $$->name, $1->name, $3->name);
    }
  | C { $$ = $1; }
;
C
  : ID {
         $$ = malloc(sizeof(Node));
    strcpy($$->name, lookup_temp($1)); // t1, t2, t3
    strcpy($$->code, ""); 
    }
  | NUM {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, newtemp());
        sprintf($$->code, "%s = %d\n", $$->name, $1);
    }
  | '(' E ')' { $$ = $2; }
  | C INC {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, $1->name);
        sprintf($$->code, "%s%s = %s + 1\n", $1->code, $1->name, $1->name);
    }
  | C DEC {
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, $1->name);
        sprintf($$->code, "%s%s = %s - 1\n", $1->code, $1->name, $1->name);
    }
  | '(' error ')' {
        yyerror("Invalid expression inside parentheses!");
        yyerrok;
        $$ = malloc(sizeof(struct Node));
        strcpy($$->name, newtemp());
        strcpy($$->code, "");
    }
;

%%

void yyerror(const char *s) {
    if (strcmp(s, "syntax error") == 0) {
        if (first_error_line == -1)
            first_error_line = yylineno;
        return;
    }
    int line = (first_error_line != -1) ? first_error_line : yylineno;
    fprintf(stderr, "Error at line %d: %s\n", line, s);
    first_error_line = -1;
}
char* concat(const char* s1, const char* s2) {
    char* res = malloc(strlen(s1) + strlen(s2) + 1);
    strcpy(res, s1);
    strcat(res, s2);
    return res;
}
char* newtemp() {
    static char temp[10];
    sprintf(temp, "t%d", ++temp_count);
    return strdup(temp);
}
char* newlabel() {
    static char label[10];
    sprintf(label, "L%d", ++label_count);
    return strdup(label);
}
void add_var_temp(char* var, char* temp) {
    strcpy(var_table[var_count].var, var);
    strcpy(var_table[var_count].temp, temp);
    var_count++;
}

char* lookup_temp(char* var) {
    for(int i=0;i<var_count;i++)
        if(strcmp(var_table[i].var,var)==0) return var_table[i].temp;
    yyerror("Variable undeclared!");
    return var;
}
int main() {
    yyparse();
    return 0;
}

%{
#include "y.tab.h"
%}

%%

M{1,3}    { yylval.val = 1000 * yyleng; return D; }  // 1000, 2000, 3000
CM        { yylval.val = 900; return H; }
CD        { yylval.val = 400; return H; }
D?C{0,3}  {
              int val = 0;
              if (yytext[0] == 'D') val += 500;
              for (int i=0; yytext[i]; i++)
                if (yytext[i] == 'C') val += 100;
              yylval.val = val; return H;
           }

XC        { yylval.val = 90; return T; }
XL        { yylval.val = 40; return T; }
L?X{0,3}  {
              int val = 0;
              if (yytext[0] == 'L') val += 50;
              for (int i=0; yytext[i]; i++)
                if (yytext[i] == 'X') val += 10;
              yylval.val = val; return T;
           }

IX        { yylval.val = 9; return U; }
IV        { yylval.val = 4; return U; }
V?I{0,3}  {
              int val = 0;
              if (yytext[0] == 'V') val += 5;
              for (int i=0; yytext[i]; i++)
                if (yytext[i] == 'I') val += 1;
              yylval.val = val; return U;
           }

\n        { return '\n'; }
[ \t]+    { /* ignore spaces */ }
.         { /* ignore other chars */ }

%%

int yywrap() { return 1; }

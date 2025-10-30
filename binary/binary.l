%{
#include "y.tab.h"
%}

%%

[01]+  {
            int val = 0;
            for (int i = 0; yytext[i]; ++i)
                val = val * 2 + (yytext[i] - '0');
            yylval.val = val;
            return BIN;
        }

\n      { return '\n'; }
[ \t]+ { /* ignore whitespace */ }
.      { /* ignore other chars */ }

%%

int yywrap() { return 1; }

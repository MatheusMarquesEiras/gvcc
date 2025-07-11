%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>

int linha = 1;
%}

%%

\n                          { linha++; }
[ \t\r]+                   ;

"int"                      { return T_INT; }
"char"                     { return T_CHAR; }
"long"                     { return T_LONG; }
"short"                    { return T_SHORT; }
"void"                     { return T_VOID; }

"if"                       { return T_IF; }
"else"                     { return T_ELSE; }
"for"                      { return T_FOR; }
"while"                    { return T_WHILE; }
"return"                   { return T_RETURN; }
"break"                    { return T_BREAK; }
"continue"                 { return T_CONTINUE; }
"struct"                   { return T_STRUCT; }

\'(\\.|[^\\'])\' {
    if (yytext[1] == '\\') {
        switch (yytext[2]) {
            case 'n':  yylval.ival = '\n'; break;
            case 't':  yylval.ival = '\t'; break;
            case 'r':  yylval.ival = '\r'; break;
            case '\\': yylval.ival = '\\'; break;
            case '\'': yylval.ival = '\''; break;
            case '0':  yylval.ival = '\0'; break;
            default:   yylval.ival = yytext[2]; break;
        }
    } else {
        yylval.ival = yytext[1];
    }
    return CHAR_CONST;
}

\"[^\"]*\" {
    int len = yyleng - 2;
    char *str = (char *)malloc(len + 1);
    strncpy(str, yytext + 1, len);
    str[len] = '\0';
    yylval.sval = str;
    return STRING_CONST;
}

[0-9]+ {
    yylval.ival = atoi(yytext);
    return NUM;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.sval = strdup(yytext);
    return ID;
}

"=="                       { return T_EQ; }
"!="                       { return T_NEQ; }
"<="                       { return T_LE; }
">="                       { return T_GE; }

"&&"                       { return T_AND; }
"||"                       { return T_OR; }

"+"                        { return '+'; }
"-"                        { return '-'; }
"*"                        { return '*'; }
"/"                        { return '/'; }
"%"                        { return '%'; }

"<"                        { return '<'; }
">"                        { return '>'; }
"!"                        { return '!'; }

"("                        { return '('; }
")"                        { return ')'; }
"["                        { return '['; }
"]"                        { return ']'; }
"{"                        { return '{'; }
"}"                        { return '}'; }
";"                        { return ';'; }
","                        { return ','; }
"="                        { return '='; }

.                          { return yytext[0]; }

%%

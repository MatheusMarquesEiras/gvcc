%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;
extern int yylex(void);
extern int yyerror(const char *s);
extern int linha;
%}

%union {
    int ival;
    char *sval;
}

%left '='
%left T_OR
%left T_AND
%left T_EQ T_NEQ
%left '<' T_LE '>' T_GE
%left '+' '-'
%left '*' '/' '%'

%token <ival> NUM CHAR_CONST
%token <sval> STRING_CONST ID

%token T_INT T_CHAR T_LONG T_SHORT T_VOID
%token T_IF T_ELSE T_FOR T_WHILE T_RETURN T_BREAK T_CONTINUE T_STRUCT

%token T_AND T_OR T_EQ T_NEQ T_LE T_GE

%type <sval> varname type
%type <ival> int_val expr expr_list arg_list expr_opt expr_list_opt ptr_opt

%%

program:
    program stmt
    |
    ;

stmt:
    decl
    | func_call
    | func_def
    | flow_stmt
    | CHAR_CONST ';'                  { printf("Constante de caractere: '%c'\n", $1); }
    | STRING_CONST ';'                { printf("Constante de string: \"%s\"\n", $1); free($1); }
    | expr ';'                        { printf("Resultado da expressão: %d\n", $1); }
    | varname '=' expr ';'            { printf("Atribuição: %s = %d\n", $1, $3); free($1); }
    | expr_list ';'                   { printf("Lista de expressões aceita\n"); }
    | varname '[' expr_list ']' ';'   { printf("Acesso a array %s com lista de expressões\n", $1); free($1); }
    ;

decl:
    type ptr_opt varname ';'                    { printf("Declaração de %s com %d ponteiro(s): %s\n", $1, $2, $3); free($1); free($3); }
    | type ptr_opt varname '=' expr ';'        { printf("%s com %d ponteiro(s): %s = %d\n", $1, $2, $3, $5); free($1); free($3); }
    ;

ptr_opt:
    '*' ptr_opt    { $$ = $2 + 1; }
    |              { $$ = 0; }
    ;

func_call:
    varname '(' ')' ';' {
        printf("Chamada de função: %s()\n", $1);
        free($1);
    }
    | varname '(' arg_list ')' ';' {
        printf("Chamada de função com argumentos: %s(...)\n", $1);
        free($1);
    }
    ;

func_def:
    type ptr_opt varname '(' ')' '{' stmt_list '}' {
        printf("Definição de função: %s com %d ponteiro(s): %s() { ... }\n", $1, $2, $3); free($1); free($3);
    }
    | type ptr_opt varname '(' arg_list ')' '{' stmt_list '}' {
        printf("Definição de função com argumentos: %s com %d ponteiro(s): %s(...) { ... }\n", $1, $2, $3); free($1); free($3);
    }
    ;

flow_stmt:
    T_IF '(' expr ')' '{' stmt_list '}'                                 { printf("if(condição) { ... }\n"); }
    | T_IF '(' expr ')' '{' stmt_list '}' T_ELSE '{' stmt_list '}'      { printf("if(condição) { ... } else { ... }\n"); }
    | T_IF '(' expr ')' '{' stmt_list '}' T_ELSE flow_stmt              { printf("if(condição) { ... } else if()...\n"); }
    | T_WHILE '(' expr ')' '{' stmt_list '}'                            { printf("while(condição) { ... }\n"); }
    | T_FOR '(' expr_list_opt ';' expr_opt ';' expr_list_opt ')' '{' stmt_list '}' {
        printf("for(...;...;...) { ... }\n");
    }
    | T_STRUCT ID '{' '}'                                               { printf("struct %s { ... }\n", $2); free($2); }
    | T_RETURN ';'                                                      { printf("return;\n"); }
    | T_RETURN NUM ';'                                                  { printf("return %d;\n", $2); }
    | T_BREAK ';'                                                       { printf("break;\n"); }
    | T_CONTINUE ';'                                                    { printf("continue;\n"); }
    ;

stmt_list:
    stmt
    | stmt_list stmt
    ;

varname:
    ID { $$ = $1; }
    ;

int_val:
    NUM { $$ = $1; }
    ;

expr_list:
    expr                      { $$ = $1; }
    | expr_list ',' expr      { $$ = $1; }
    ;

expr_list_opt:
    expr_list                 { $$ = $1; }
    |                        { $$ = 0; }
    ;

expr_opt:
    expr                     { $$ = $1; }
    |                        { $$ = 0; }
    ;

arg_list:
    expr                      { $$ = $1; }
    | arg_list ',' expr       { $$ = $1; }
    ;

expr:
    expr '=' expr      { $$ = $3; }
    | expr T_OR expr   { $$ = $1 || $3; }
    | expr T_AND expr  { $$ = $1 && $3; }
    | expr T_EQ expr   { $$ = $1 == $3; }
    | expr T_NEQ expr  { $$ = $1 != $3; }
    | expr '<' expr    { $$ = $1 < $3; }
    | expr T_LE expr   { $$ = $1 <= $3; }
    | expr '>' expr    { $$ = $1 > $3; }
    | expr T_GE expr   { $$ = $1 >= $3; }
    | expr '+' expr    { $$ = $1 + $3; }
    | expr '-' expr    { $$ = $1 - $3; }
    | expr '*' expr    { $$ = $1 * $3; }
    | expr '/' expr    { $$ = $3 != 0 ? $1 / $3 : 0; }
    | expr '%' expr    { $$ = $3 != 0 ? $1 % $3 : 0; }
    | '!' expr         { $$ = !$2; }
    | '(' expr ')'     { $$ = $2; }
    | int_val          { $$ = $1; }
    | CHAR_CONST       { $$ = $1; }
    | ID               { $$ = 0; }
    ;

type:
    T_INT     { $$ = strdup("int"); }
    | T_CHAR  { $$ = strdup("char"); }
    | T_LONG  { $$ = strdup("long"); }
    | T_SHORT { $$ = strdup("short"); }
    | T_VOID  { $$ = strdup("void"); }
    ;

%%

int main() {
    FILE *arquivo = fopen("a.cmm", "r");
    if (!arquivo) {
        perror("Erro ao abrir o arquivo");
        return 1;
    }

    yyin = arquivo;
    yyparse();
    fclose(arquivo);
    return 0;
}


int yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe na linha %d: %s\n", linha, s);
    return 1;
}
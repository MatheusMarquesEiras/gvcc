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

%token <ival> NUM
%token <ival> CHAR_CONST
%token <sval> STRING_CONST
%token <sval> ID

%token T_INT T_CHAR T_LONG T_SHORT T_VOID
%token T_IF T_ELSE T_FOR T_WHILE T_RETURN T_BREAK T_CONTINUE T_STRUCT

%type <sval> varname
%type <ival> int_val
%type <sval> type

%%

program:
    program stmt
    | /* vazio */
    ;

stmt:
    decl
    | func_call
    | func_def
    | flow_stmt
    | CHAR_CONST ';'           { printf("Constante de caractere: '%c'\n", $1); }
    | STRING_CONST ';'         { printf("Constante de string: \"%s\"\n", $1); free($1); }
    ;

decl:
    type varname ';'                    { printf("Declaração de %s: %s\n", $1, $2); free($1); free($2); }
    | type varname '=' int_val ';'     { printf("%s %s = %d\n", $1, $2, $4); free($1); free($2); }
    ;

func_call:
    varname '(' ')' ';' {
        printf("Chamada de função: %s()\n", $1);
        free($1);
    }
    ;

func_def:
    type varname '(' ')' '{' '}' {
        printf("Definição de função: %s %s() { }\n", $1, $2);
        free($1); free($2);
    }
    ;

flow_stmt:
    T_IF '(' ')' '{' '}'                          { printf("if() { ... }\n"); }
    | T_IF '(' ')' '{' '}' T_ELSE '{' '}'         { printf("if() { ... } else { ... }\n"); }
    | T_WHILE '(' ')' '{' '}'                     { printf("while() { ... }\n"); }
    | T_FOR '(' ')' '{' '}'                       { printf("for() { ... }\n"); }
    | T_STRUCT ID '{' '}'                         { printf("struct %s { ... }\n", $2); free($2); }
    | T_RETURN ';'                                { printf("return;\n"); }
    | T_RETURN NUM ';'                            { printf("return %d;\n", $2); }
    | T_BREAK ';'                                 { printf("break;\n"); }
    | T_CONTINUE ';'                              { printf("continue;\n"); }
    ;

varname:
    ID { $$ = $1; }
    ;

int_val:
    NUM { $$ = $1; }
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
    FILE *arquivo = fopen("a.txt", "r");
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

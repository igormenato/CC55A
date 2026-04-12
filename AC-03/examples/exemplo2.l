%option noyywrap noinput nounput

%top{
#define _POSIX_C_SOURCE 200809L
}

%{
#include <stdio.h>

static int linhas = 0;
static int caracteres = 0;
static int tabs = 0;
static int saw_input = 0;
static int ended_with_newline = 1;
%}

%%
\n { ++linhas; ++caracteres; saw_input = 1; ended_with_newline = 1; }
\t { ++tabs; saw_input = 1; ended_with_newline = 0; }
.  { ++caracteres; saw_input = 1; ended_with_newline = 0; }
%%

int main(void) {
    yylex();
    if (saw_input && !ended_with_newline) {
        ++linhas;
    }
    printf("Numero linhas: %d\n", linhas);
    printf("Numero tabulacoes: %d\n", tabs);
    printf("Numero caracteres: %d\n", caracteres);
    return 0;
}

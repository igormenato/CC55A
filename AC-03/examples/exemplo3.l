%option noyywrap noinput nounput

%top{
#define _POSIX_C_SOURCE 200809L
}

%{
#include <stdio.h>

static int linhas = 0;
static int saw_input = 0;
static int ended_with_newline = 1;
static int last_was_newline = 1;
%}

TAG         \<[^>\n]*\>
WHITESPACE  [ \t]+
LINHA       \n

%%
{TAG}        { saw_input = 1; ended_with_newline = 0; }
{LINHA}      { ++linhas; saw_input = 1; ended_with_newline = 1; putchar('\n'); last_was_newline = 1; }
{WHITESPACE} { fputs(yytext, stdout); saw_input = 1; ended_with_newline = 0; last_was_newline = 0; }
.            { fputs(yytext, stdout); saw_input = 1; ended_with_newline = 0; last_was_newline = 0; }
%%

int main(void) {
    yylex();
    if (saw_input && !ended_with_newline) {
        ++linhas;
    }
    if (!last_was_newline) {
        putchar('\n');
    }
    printf("Total de linhas processadas: %d\n", linhas);
    return 0;
}

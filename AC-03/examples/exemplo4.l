%option noyywrap noinput nounput

%top{
#define _POSIX_C_SOURCE 200809L
}

%{
#include <stdio.h>

static int linhas = 0;
static int qtd_tags = 0;
static int saw_input = 0;
static int ended_with_newline = 1;
%}

TAG         \<[^>\n]*\>
WHITESPACE  [ \t]+
LINHA       \n
LETT1       [a-z]+
LETT2       [A-Z]+
WORD        [A-Z][a-z]+

%%
{TAG}        { saw_input = 1; ended_with_newline = 0; ++qtd_tags; printf("Tag: %s\n", yytext); }
{WORD}       { saw_input = 1; ended_with_newline = 0; printf("Wort: %s\n", yytext); }
{LETT2}      { saw_input = 1; ended_with_newline = 0; printf("mai: %s\n", yytext); }
{LETT1}      { saw_input = 1; ended_with_newline = 0; printf("min: %s\n", yytext); }
{LINHA}      { ++linhas; saw_input = 1; ended_with_newline = 1; }
{WHITESPACE} { saw_input = 1; ended_with_newline = 0; }
.            { saw_input = 1; ended_with_newline = 0; }
%%

int main(void) {
    yylex();
    if (saw_input && !ended_with_newline) {
        ++linhas;
    }
    printf("Total de linhas processadas: %d\n", linhas);
    printf("Quantidade de tags reconhecidas: %d\n", qtd_tags);
    return 0;
}

%option noyywrap noinput nounput

%top{
#define _POSIX_C_SOURCE 200809L
}

%{
#include <stdio.h>

static void print_escaped_token(const char *label, const char *lexeme) {
    const unsigned char *p = (const unsigned char *) lexeme;

    printf("%s: \"", label);
    for (; *p != '\0'; ++p) {
        switch (*p) {
            case '\n':
                printf("\\n");
                break;
            case '\t':
                printf("\\t");
                break;
            case '\r':
                printf("\\r");
                break;
            case '\\':
                printf("\\\\");
                break;
            case '"':
                printf("\\\"");
                break;
            default:
                putchar(*p);
                break;
        }
    }
    printf("\"\n");
}
%}

DIGITO  [0-9]
PALAVRA [A-Za-z]+

%%
{DIGITO}  { print_escaped_token("Digito", yytext); }
{PALAVRA} { print_escaped_token("Palavra", yytext); }
\n        { print_escaped_token("Nao reconhecido", yytext); }
.         { print_escaped_token("Nao reconhecido", yytext); }
%%

int main(void) {
    yylex();
    return 0;
}

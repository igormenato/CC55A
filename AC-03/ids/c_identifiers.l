%option noyywrap noinput nounput

%top{
#define _POSIX_C_SOURCE 200809L
}

%{
#include <ctype.h>
#include <stdio.h>
#include <string.h>

static int is_identifier_start(unsigned char c) {
    return isalpha(c) || c == '_';
}

static int is_identifier_continue(unsigned char c) {
    return isalnum(c) || c == '_';
}

static int is_c_keyword(const char *lexeme) {
    static const char *keywords[] = {
        "auto", "break", "case", "char", "const", "continue", "default", "do",
        "double", "else", "enum", "extern", "float", "for", "goto", "if",
        "inline", "int", "long", "register", "restrict", "return", "short",
        "signed", "sizeof", "static", "struct", "switch", "typedef", "union",
        "unsigned", "void", "volatile", "while", "_Alignas", "_Alignof",
        "_Atomic", "_Bool", "_Complex", "_Generic", "_Imaginary", "_Noreturn",
        "_Static_assert", "_Thread_local"
    };
    size_t i;

    for (i = 0; i < sizeof(keywords) / sizeof(keywords[0]); ++i) {
        if (strcmp(lexeme, keywords[i]) == 0) {
            return 1;
        }
    }
    return 0;
}

static void classify_identifier(const char *lexeme) {
    size_t i;

    if (lexeme[0] == '\0') {
        return;
    }

    if (!is_identifier_start((unsigned char) lexeme[0])) {
        if (isdigit((unsigned char) lexeme[0])) {
            printf("ID_INVALIDO_INICIA_COM_DIGITO: %s\n", lexeme);
        } else {
            printf("ID_INVALIDO_CARACTERE: %s\n", lexeme);
        }
        return;
    }

    for (i = 1; lexeme[i] != '\0'; ++i) {
        if (!is_identifier_continue((unsigned char) lexeme[i])) {
            printf("ID_INVALIDO_CARACTERE: %s\n", lexeme);
            return;
        }
    }

    if (is_c_keyword(lexeme)) {
        printf("PALAVRA_RESERVADA: %s\n", lexeme);
        return;
    }

    printf("ID_VALIDO: %s\n", lexeme);
}
%}

ID_VALIDO        [A-Za-z_][A-Za-z0-9_]*
ID_NUMERO_INICIO [0-9][A-Za-z0-9_]*
DELIMITADOR      [ \t\r\n;,\(\)\{\}\[\]\.\+\-\*\/%&|^~!=<>?:#'\"\\]+
CANDIDATO        [^ \t\r\n;,\(\)\{\}\[\]\.\+\-\*\/%&|^~!=<>?:#'\"\\]+

%%
{ID_VALIDO}        { classify_identifier(yytext); }
{ID_NUMERO_INICIO} { classify_identifier(yytext); }
{DELIMITADOR}      { }
{CANDIDATO}        { classify_identifier(yytext); }
%%

int main(void) {
    yylex();
    return 0;
}

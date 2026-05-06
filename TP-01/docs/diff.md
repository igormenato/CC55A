### 1. `bison-calc.h`

```diff
--- ref/src/bison-calc.h
+++ src/bison-calc.h
@@ -5,6 +5,8 @@
 /* interface com o lexer */
 extern int yylineno;
 void yyerror(char *s, ...);
+int yylex(void);
+int yyparse(void);
 
 /* tab. de simbolos */
 struct symbol {         /* um nome de variavel */
@@ -16,7 +18,7 @@
 
 /* tab. de simbolos de tamanho fixo */
 #define NHASH 9997
-struct symbol symtab[NHASH];
+extern struct symbol symtab[NHASH];
 
 struct symbol *lookup(char *);
 
@@ -34,6 +36,9 @@
  * L expressao ou lista de comandos
  * I comando IF
  * W comando WHILE
+ * R comando FOR
+ * A operador AND
+ * O operador OR
  * N symbol de referencia
  * = atribuicao
  * S lista de simbolos
@@ -74,6 +79,15 @@
     struct ast *el;     /* ramo opcional "else" */
 };
 
+struct forloop {
+    int nodetype;       /* tipo R */
+    struct ast *init;   /* inicializacao */
+    struct ast *cond;   /* condicao */
+    struct ast *inc;    /* incremento */
+    struct ast *body;   /* corpo do laco */
+};
+
 struct numval {
     int nodetype;       /* tipo K */
     double number;
@@ -100,5 +114,6 @@
 struct ast *newnum(double d);
 struct ast *newflow(int nodetype, struct ast *cond, struct ast *tl, struct ast *tr);
+struct ast *newfor(int nodetype, struct ast *init, struct ast *cond, struct ast *inc, struct ast *body);
 
 /* definicao de uma funcao */
```

---

### 2. `calc_aux.c`

```diff
--- ref/src/calc_aux.c
+++ src/calc_aux.c
@@ -1,6 +1,7 @@
 /*
- * Funcoes Auxiliares para uma calculadora avancada
+ * Funcoes Auxiliares
  */
 #include <stdio.h>
 #include <stdlib.h>
 #include <stdarg.h>
@@ -9,6 +10,8 @@
 #include <math.h>
 #include "bison-calc.h"
 
+struct symbol symtab[NHASH];
+
 /* funcoes em C para TS */
 /* funcao hashing */
 static unsigned symhash(char *sym)
@@ -155,6 +158,19 @@
     return (struct ast *)a;
 }
 
+struct ast *newfor(int nodetype, struct ast *init, struct ast *cond, struct ast *inc, struct ast *body)
+{
+    struct forloop *a = malloc(sizeof(struct forloop));
+
+    if (!a) {
+        yyerror("sem espaco");
+        exit(0);
+    }
+    a->nodetype = nodetype;
+    a->init = init;
+    a->cond = cond;
+    a->inc = inc;
+    a->body = body;
+    return (struct ast *)a;
+}
+
 /* libera uma arvore de AST */
 void treefree(struct ast *a)
 {
@@ -167,6 +183,8 @@
     case '/':
     case '1': case '2': case '3': case '4': case '5': case '6':
     case 'L':
+    case 'A':
+    case 'O':
         treefree(a->r);
 
         /* uma subarvore */
@@ -189,6 +207,14 @@
         if (((struct flow *)a)->el) treefree(((struct flow *)a)->el);
         break;
 
+    case 'R':
+        free(((struct forloop *)a)->init);
+        free(((struct forloop *)a)->cond);
+        free(((struct forloop *)a)->inc);
+        if (((struct forloop *)a)->body) treefree(((struct forloop *)a)->body);
+        break;
+
     default: printf("erro interno: free bad node %c\n", a->nodetype);
     }
 
@@ -256,6 +282,10 @@
     case '6': v = (eval(a->l) <= eval(a->r)) ? 1 : 0; break;
 
+    /* operadores logicos */
+    case 'A': v = (eval(a->l) != 0 && eval(a->r) != 0) ? 1 : 0; break;
+    case 'O': v = (eval(a->l) != 0 || eval(a->r) != 0) ? 1 : 0; break;
+
     /* controle de fluxo */
     /* gramatica permite expressoes vazias, entao devem ser verificadas */
 
@@ -287,6 +317,18 @@
         break;      /* valor do ultimo comando eh valor do while/do */
 
+        /* for */
+    case 'R':
+        v = 0.0;    /* valor default */
+
+        eval(((struct forloop *)a)->init);              /* inicializacao */
+
+        if (((struct forloop *)a)->body) {              /* testa se lista de comandos nao eh vazia */
+            while (eval(((struct forloop *)a)->cond) != 0) { /* avalia a condicao */
+                v = eval(((struct forloop *)a)->body);  /* avalia comandos */
+                eval(((struct forloop *)a)->inc);       /* incremento */
+            }
+        }
+        break;
+
     /* lista de comandos */
     case 'L': eval(a->l); v = eval(a->r); break;
```

---

### 3. `lexer.l`

```diff
--- ref/src/lexer.l
+++ src/lexer.l
@@ -3,7 +3,7 @@
  */
 
 /* reconhecimento de tokens para a calculadora */
-%option noyywrap nodefault yylineno
+%option noyywrap nodefault yylineno noinput nounput
 
 %{
 #include "bison-calc.h"
@@ -37,6 +37,9 @@
 "while" { return WHILE; }
 "do"    { return DO; }
 "let"   { return LET; }
+"for"   { return FOR; }
+"and"   { return AND; }
+"or"    { return OR; }
 
 "sqrt"  { yylval.fn = B_sqrt; return FUNC; }   /* funcoes pre-definidas */
 "exp"   { yylval.fn = B_exp; return FUNC; }
```

---

### 4. `lexer.l`

```diff
--- ref/src/parser.y
+++ src/parser.y
@@ -23,7 +23,7 @@
 %token <fn> FUNC
 %token EOL
 
-%token IF THEN ELSE WHILE DO LET
+%token IF THEN ELSE WHILE DO LET FOR AND OR
 
+%left OR
+%left AND
 %nonassoc <fn> CMP
 %right '='
@@ -38,6 +38,7 @@
 stmt: IF exp THEN list           { $$ = newflow('I', $2, $4, NULL); }
     | IF exp THEN list ELSE list { $$ = newflow('I', $2, $4, $6); }
     | WHILE exp DO list          { $$ = newflow('W', $2, $4, NULL); }
+    | FOR '(' exp ';' exp ';' exp ')' list { $$ = newfor('R', $3, $5, $7, $9); }
     | exp
     ;
 
@@ -51,6 +52,8 @@
     ;
 
 exp: exp CMP exp            { $$ = newcmp($2, $1, $3); }
+   | exp AND exp            { $$ = newast('A', $1, $3); }
+   | exp OR exp             { $$ = newast('O', $1, $3); }
    | exp '+' exp            { $$ = newast('+', $1, $3); }
    | exp '-' exp            { $$ = newast('-', $1, $3); }
    | exp '*' exp            { $$ = newast('*', $1, $3); }
```

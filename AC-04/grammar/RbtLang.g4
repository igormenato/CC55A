grammar RbtLang;

/*
 * Gramatica da linguagem rbtlang
 */

program
    : statement (',' statement)* EOF
    ;

statement
    : move
    | ifStmt
    ;

move
    : 'move' '(' direction ',' INT ')'
    ;

direction
    : 'up'
    | 'down'
    | 'left'
    | 'right'
    ;

ifStmt
    : 'if' condition 'then' action
    ;

condition
    : 'obst'
    | 'box'
    ;

action
    : move
    | 'collect'
    | 'push'
    ;

INT
    : [0-9]+
    ;

ID
    : [a-zA-Z]+
    ;

WS
    : [ \t\r\n]+ -> skip
    ;

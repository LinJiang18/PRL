%{
    void yyerror (char *s);
    int yylex();
    #include <stdio.h>
    #include <stdlib.h>
    #include "ast.h"
%}

%union {
    int ival;
    char * sval;
}

%start program
%token DEFINEFUN
%token PRINT
%token <ival> CONST
%token LEFT RIGHT
%token <sval> VARNAME
%token <sval>TRUE
%token <sval>FALSE
%token INT BOOL

%token <sval>GETINT 
%token <sval>GETBOOL
%token ADD MINUS MUL DIV MOD
%token SMALLER GREATER NOTGREATER NOTSMALLER EQUAL
%token AND OR NOT
%token IF
%token LET
%token <sval> STRCONST
%type <ival>expr

%type <ival>retexprType
%type <ival> exprType
%type <sval>var fun
%type <ival>varint funint

%type <ival>inputlist
%type <ival>inputlistentry
%type <ival>addTerm
%type <ival>minusTerm
%type <ival>multiplyTerm
%type <ival>divTerm
%type <ival>modTerm
%type <ival>oneExprOrMore
%type <ival>definefun
%type <ival>exprlist
%type <ival>entry
%type <ival>mainexpr
%type <ival>empty
%%

program : definefun program  {}
        | entry mainexpr {insert_children(2, $1, $2); insert_node("entry", 1);}
entry : LEFT {$$ = insert_node("main", 0);}
mainexpr : PRINT expr RIGHT {
                insert_child($2);
                $$ = insert_node("call PRINT", 1);
        }
definefun : LEFT DEFINEFUN funint inputlistentry retexprType expr RIGHT {
                insert_children(4, $3, $4, $5, $6); 
                $$ = insert_node("definefun", 0);
                }

inputlistentry  : inputlist {insert_child($1); $$ = insert_node("inputlist", 0);}
inputlist: empty {$$ = $1;}
        | LEFT varint exprType RIGHT  {$$ = $2; } 
        | LEFT varint exprType RIGHT inputlist {
                $$ = $2; 
                insert_child($5);
                } 
exprType: INT {}
        | BOOL  {}
retexprType: INT  {$$ = insert_node("ret INT", 3); }
        | BOOL {$$ = insert_node("ret BOOL", 4);}
expr    : CONST {char* str = (char*)malloc(12 * sizeof(char)); sprintf(str, "%d", $1); $$ = insert_node(str,1); }
        | varint { $$ = $1;}
        | LEFT GETINT RIGHT{
                $$ = insert_node("GETINT", 6);
                }
        | TRUE{$$ = insert_node("true", 7); }
        | FALSE{$$ = insert_node("false", 8); }
        | LEFT GETBOOL RIGHT{ $$ = insert_node("GETBOOL", 9); }
        | addTerm{$$ = $1;}
        | multiplyTerm{$$ = $1; }
        | minusTerm{$$ = $1; }
        | divTerm{$$ = $1; }
        | modTerm{$$ = $1; }
        | LEFT IF expr expr expr RIGHT{insert_child($3); insert_child($4);insert_child($5);$$ = insert_node("if", 10);}
        | LEFT funint exprlist RIGHT{ 
                insert_children(2, $2, $3); 
                $$ = insert_node("call func", 1);
                }
        | LEFT LET LEFT varint expr RIGHT expr RIGHT {
                insert_children(3, $4, $5, $7);
                $$ = insert_node("let", 12);
                }
        | LEFT EQUAL expr expr RIGHT{insert_child($3); insert_child($4);$$ = insert_node("equal", 13);}
        | LEFT SMALLER expr expr RIGHT{insert_child($3); insert_child($4);$$ = insert_node("smaller", 14);}
        | LEFT GREATER expr expr RIGHT{insert_child($3); insert_child($4);$$ = insert_node("greater", 15);}
        | LEFT NOTGREATER expr expr RIGHT{insert_child($3); insert_child($4);$$ = insert_node("notgreater", 16);}
        | LEFT NOTSMALLER expr expr RIGHT{insert_child($3); insert_child($4);$$ = insert_node("notsmallar", 17);}
        | LEFT NOT expr RIGHT{insert_child($3);$$ = insert_node("not", 18);}
        | LEFT AND expr oneExprOrMore RIGHT{insert_child($3);insert_child($4);$$ = insert_node("and", 19);}
        | LEFT OR expr oneExprOrMore RIGHT{insert_child($3);insert_child($4);$$ = insert_node("or", 20);}

       
oneExprOrMore   : expr{$$ = $1;}
                | expr oneExprOrMore{$$ = $1; insert_child($2);}
addTerm : LEFT ADD expr oneExprOrMore RIGHT{
        insert_child($3); 
        insert_child($4);
        $$ = insert_node("add", 0); 
        }
multiplyTerm    : LEFT MUL expr oneExprOrMore RIGHT{
        insert_child($3); 
        insert_child($4);
        $$ = insert_node("mul", 0); 
        }
minusTerm   : LEFT MINUS expr expr RIGHT{
        insert_child($3); 
        insert_child($4);
        $$ = insert_node("minus", 0); 
        }
divTerm : LEFT DIV expr expr RIGHT{
        insert_child($3); 
        insert_child($4);
        $$ = insert_node("div", 0); 
        }
modTerm : LEFT MOD expr expr RIGHT{
        insert_child($3); 
        insert_child($4);
        $$ = insert_node("mod", 0); 
        }

exprlist    : empty {$$ = $1;}
            | expr {$$ = $1;}
            | expr exprlist {$$ = $1; insert_child($2);}
funint : fun {char* str = (char*)malloc(12 * sizeof(char)); strcpy(str, $1);  $$ = insert_node(str, 1);}
varint : var {char* str = (char*)malloc(12 * sizeof(char)); strcpy(str, $1);  $$ = insert_node(str, 1);}
empty : /* empty */ {$$ = insert_node("none", 1); }
fun : VARNAME 
var : VARNAME 
%%
//
//
//
//int main(void) { return yyparse();}

void yyerror (char *s) {printf ("%s\n", s); }

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror (char const *s);
extern int get_line_number();
extern void *arvore;

%}

%code requires {
    #include "ast.h"
}

%union {
    lexical_value_t lexical_value;
    ast_t *tree;
}

%token<lexical_value> TK_PR_INT
%token<lexical_value> TK_PR_FLOAT
%token<lexical_value> TK_PR_BOOL
%token<lexical_value> TK_PR_IF
%token<lexical_value> TK_PR_ELSE
%token<lexical_value> TK_PR_WHILE
%token<lexical_value> TK_PR_RETURN
%token<lexical_value> TK_OC_LE
%token<lexical_value> TK_OC_GE
%token<lexical_value> TK_OC_EQ
%token<lexical_value> TK_OC_NE
%token<lexical_value> TK_OC_AND
%token<lexical_value> TK_OC_OR
%token<lexical_value> TK_OC_MAP
%token<lexical_value> TK_IDENTIFICADOR
%token<lexical_value> TK_LIT_INT
%token<lexical_value> TK_LIT_FLOAT
%token<lexical_value> TK_LIT_FALSE
%token<lexical_value> TK_LIT_TRUE
%token<lexical_value> '-'
%token<lexical_value> '!'
%token<lexical_value> '*'
%token<lexical_value> '/'
%token<lexical_value> '%'
%token<lexical_value> '+'
%token<lexical_value> '<'
%token<lexical_value> '>'
%token<lexical_value> '{'
%token<lexical_value> '}'
%token<lexical_value> '('
%token<lexical_value> ')'
%token<lexical_value> '='
%token<lexical_value> ','
%token<lexical_value> ';'
%token<lexical_value> TK_ERRO

%type<tree> program
%type<tree> global_declarations
%type<tree> function_declaration
%type<tree> l_params
%type<tree> global_variable_declaration
%type<tree> l_global_variables
%type<tree> command_block
%type<tree> l_commands
%type<tree> command
%type<tree> local_variables_declaration
%type<tree> l_local_variables
%type<tree> attribuition
%type<tree> control_flow
%type<tree> if_statement
%type<tree> while_statement
%type<tree> return_operation
%type<tree> function_call
%type<tree> l_args
%type<tree> expression
%type<tree> or_expression
%type<tree> and_expression
%type<tree> equality_expression
%type<tree> relational_expression
%type<tree> additive_expression
%type<tree> multiplicative_expression
%type<tree> unary_expression
%type<tree> operand
%type<tree> type
%type<tree> literal

%define parse.error verbose

%%

program
    : { arvore = NULL; }
    | global_declarations { arvore = $<tree>1; }
    ;

global_declarations
    : function_declaration { $<tree>$ = $<tree>1; }
    | global_variable_declaration
    | global_declarations function_declaration {
        if ($<tree>1 == NULL) {
            $<tree>$ = $<tree>2;
        } else {
            $<tree>$ = $<tree>1;
            ast_append_next($<tree>$, $<tree>2);
        }
    }
    | global_declarations global_variable_declaration
    ;

function_declaration
    : TK_IDENTIFICADOR '(' l_params ')' TK_OC_MAP type command_block {
        $<tree>$ = ast_new($<lexical_value>1);
        ast_add_child($<tree>$, $<tree>7);
    }
    | TK_IDENTIFICADOR '(' ')' TK_OC_MAP type command_block {
        $<tree>$ = ast_new($<lexical_value>1);
        ast_add_child($<tree>$, $<tree>6);
    }
    ;

l_params
    : type TK_IDENTIFICADOR
    | l_params ',' type TK_IDENTIFICADOR
    ;

global_variable_declaration
    : type l_global_variables ';'
    ;

l_global_variables
    : TK_IDENTIFICADOR { }
    | l_global_variables ',' TK_IDENTIFICADOR
    ;

command_block
    : '{' l_commands '}' { $<tree>$ = $<tree>2; }
    | '{' '}' { $<tree>$ = NULL; }
    ;

l_commands
    : command ';' { $<tree>$ = $<tree>1; }
    | l_commands command ';' {
        if ($<tree>1 == NULL) {
            $<tree>$ = $<tree>2;
        } else {
            $<tree>$ = $<tree>1;
            ast_append_next($<tree>$, $<tree>2);
        }
    }
    ;

command
    : local_variables_declaration { $<tree>$ = $<tree>1; }
    | attribuition { $<tree>$ = $<tree>1; }
    | control_flow { $<tree>$ = $<tree>1; }
    | return_operation { $<tree>$ = $<tree>1; }
    | command_block { $<tree>$ = $<tree>1; }
    | function_call { $<tree>$ = $<tree>1; }
    ;

local_variables_declaration
    : type l_local_variables { $<tree>$ = $<tree>2; }

l_local_variables
    : TK_IDENTIFICADOR { $<tree>$ = NULL; }
    | TK_IDENTIFICADOR TK_OC_LE literal {  
        $<tree>$ = ast_new($<lexical_value>2);
        ast_add_child($<tree>$, ast_new($<lexical_value>1));
        ast_add_child($<tree>$, $<tree>3);
    }
    | l_local_variables ',' TK_IDENTIFICADOR  { $<tree>$ = $<tree>1; }
    | l_local_variables ',' TK_IDENTIFICADOR TK_OC_LE literal {
        if ($<tree>1 == NULL) {
            $<tree>$ = ast_new($<lexical_value>4);
            ast_add_child($$, ast_new($<lexical_value>3));
            ast_add_child($$, $<tree>5);
        } else { 
            $<tree>$ = $<tree>1; 
            ast_t* aux = ast_new($<lexical_value>4); 
            ast_add_child(aux, ast_new($<lexical_value>3));
            ast_add_child(aux, $<tree>5);
            ast_append_next($<tree>$, aux);
        }
    }
    ;

attribuition
    : TK_IDENTIFICADOR '=' expression {
        $<tree>$ = $<tree>$ = ast_new($<lexical_value>2);
        ast_add_child($<tree>$, ast_new($<lexical_value>1));
        ast_add_child($<tree>$, $<tree>3);
    }
    ;

control_flow
    : if_statement { $<tree>$ = $<tree>1; }
    | while_statement { $<tree>$ = $<tree>1; }
    ;

if_statement
    : TK_PR_IF '(' expression ')' command_block {
        $<tree>$ = ast_new($<lexical_value>1);
        ast_add_child($<tree>$, $<tree>3);
        ast_add_child($<tree>$, $<tree>5);
    }
    | TK_PR_IF '(' expression ')' command_block TK_PR_ELSE command_block {
        $<tree>$ = ast_new($<lexical_value>1);
        ast_add_child($<tree>$, $<tree>3);
        ast_add_child($<tree>$, $<tree>5);
        ast_add_child($<tree>$, $<tree>7);
    }
    ;

while_statement
    : TK_PR_WHILE '(' expression ')' command_block {
        $<tree>$ = ast_new($<lexical_value>1);
        ast_add_child($<tree>$, $<tree>3);
        ast_add_child($<tree>$, $<tree>5);
    }
    ;

return_operation
    : TK_PR_RETURN expression {
        $<tree>$ = ast_new($<lexical_value>1);
        ast_add_child($<tree>$, $<tree>2);
    }

function_call
    : TK_IDENTIFICADOR '(' l_args ')' {
        $<tree>$ = ast_new($<lexical_value>1);
        ast_add_child($<tree>$, $<tree>3);
        char *new_label = strdup("call ");
        strcat(new_label, $<tree>$->lexical_value.label);
        ast_update_label($<tree>$, new_label);
    }
    | TK_IDENTIFICADOR '(' ')' {
        $<tree>$ = ast_new($<lexical_value>1);
        char *new_label = strdup("call ");
        strcat(new_label, $<tree>$->lexical_value.label);
        ast_update_label($<tree>$, new_label);
    }
    ;

l_args
    : expression { $<tree>$ = $<tree>1; }
    | l_args ',' expression {
        $<tree>$ = $<tree>1;
        ast_append_next($<tree>$, $<tree>3);
    }
    ;

expression 
    : or_expression { $<tree>$ = $<tree>1; }
    ;

or_expression
    : or_expression TK_OC_OR and_expression {
        $<tree>$ = ast_new($<lexical_value>2);
        ast_add_child($<tree>$, $<tree>1);
        ast_add_child($<tree>$, $<tree>3);
    }
    | and_expression { $<tree>$ = $<tree>1; }
    ;

and_expression
    : and_expression TK_OC_AND equality_expression {
        $<tree>$ = ast_new($<lexical_value>2);
        ast_add_child($<tree>$, $<tree>1);
        ast_add_child($<tree>$, $<tree>3);
    }
    | equality_expression { $<tree>$ = $<tree>1; }
    ;

equality_operators
    : TK_OC_NE { $<tree>$ = ast_new($<lexical_value>1); }
    | TK_OC_EQ { $<tree>$ = ast_new($<lexical_value>1); }
    ;

equality_expression
    : equality_expression equality_operators relational_expression {
        $<tree>$ = $<tree>2;
        ast_add_child($<tree>$, $<tree>1);
        ast_add_child($<tree>$, $<tree>3);
    }
    | relational_expression { $<tree>$ = $<tree>1; }
    ;

relational_operators
    : '<' { $<tree>$ = ast_new($<lexical_value>1); }
    | '>' { $<tree>$ = ast_new($<lexical_value>1); }
    | TK_OC_LE { $<tree>$ = ast_new($<lexical_value>1); }
    | TK_OC_GE { $<tree>$ = ast_new($<lexical_value>1); }
    ;

relational_expression
    : relational_expression relational_operators additive_expression {
        $<tree>$ = $<tree>2;
        ast_add_child($<tree>$, $<tree>1);
        ast_add_child($<tree>$, $<tree>3);
    }
    | additive_expression { $<tree>$ = $<tree>1; }
    ;

additive_operators
    : '+' { $<tree>$ = ast_new($<lexical_value>1); }
    | '-' { $<tree>$ = ast_new($<lexical_value>1); }
    ;

additive_expression
    : additive_expression additive_operators multiplicative_expression {
         $<tree>$ = $<tree>2;
        ast_add_child($<tree>$, $<tree>1);
        ast_add_child($<tree>$, $<tree>3);
    }
    | multiplicative_expression { $<tree>$ = $<tree>1; }
    ;

multiplicative_operators
    : '*' { $<tree>$ = ast_new($<lexical_value>1); }
    | '/' { $<tree>$ = ast_new($<lexical_value>1); }
    | '%' { $<tree>$ = ast_new($<lexical_value>1); }
    ;

multiplicative_expression
    : multiplicative_expression multiplicative_operators unary_expression {
        $<tree>$ = $<tree>2;
        ast_add_child($<tree>$, $<tree>1);
        ast_add_child($<tree>$, $<tree>3);
    }
    | unary_expression { $<tree>$ = $<tree>1; }
    ;

unary_operators
    : '-' { $<tree>$ = ast_new($<lexical_value>1); }
    | '!' { $<tree>$ = ast_new($<lexical_value>1); }
    ;

unary_expression
    : unary_operators operand {
        $<tree>$ = $<tree>1;
        ast_add_child($<tree>$, $<tree>2);
    }
    | operand { $<tree>$ = $<tree>1; }
    ;

operand
    : '(' expression ')' { $<tree>$ = $<tree>2; }
    | TK_IDENTIFICADOR { $<tree>$ = ast_new($<lexical_value>1); }
    | literal { $<tree>$ = $<tree>1; }
    | function_call { $<tree>$ = $<tree>1; }
    ;

type
    : TK_PR_INT { $<tree>$ = NULL; }
    | TK_PR_FLOAT { $<tree>$ = NULL; }
    | TK_PR_BOOL { $<tree>$ = NULL; }
    ;

literal
    : TK_LIT_INT { $<tree>$ = ast_new($<lexical_value>1); }
    | TK_LIT_FLOAT { $<tree>$ = ast_new($<lexical_value>1); }
    | TK_LIT_FALSE { $<tree>$ = ast_new($<lexical_value>1); }
    | TK_LIT_TRUE { $<tree>$ = ast_new($<lexical_value>1); }
    ;

%%

void yyerror(char const *s) {
  printf("[%d]: %s\n", get_line_number(), s);
}
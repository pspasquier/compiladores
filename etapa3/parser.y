%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror (char const *s);
extern int get_line_number();

%}

%code requires { #include "asd.h" }

%define api.value.type { asd_tree_t* }

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
%token TK_PR_IF
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_RETURN
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_OC_MAP
%token TK_IDENTIFICADOR
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_ERRO

%define parse.error verbose

%%

program
    :
    | global_declarations { asd_print_graphviz($1); asd_free($1); }
    ;

global_declarations
    : function_declaration { $$ = $1; }
    | global_variable_declaration
    | global_declarations function_declaration { $$ = $1; asd_append_next($$, $2); }
    | global_declarations global_variable_declaration
    ;

function_declaration
    : TK_IDENTIFICADOR '(' l_params ')' TK_OC_MAP type command_block { $$ = $1; asd_add_child($$, $7); }
    | TK_IDENTIFICADOR '(' ')' TK_OC_MAP type command_block { $$ = $1; asd_add_child($$, $6); }
    ;

l_params
    : type TK_IDENTIFICADOR
    | l_params ',' type TK_IDENTIFICADOR
    ;

global_variable_declaration
    : type l_global_variables ';'
    ;

l_global_variables
    : TK_IDENTIFICADOR
    | l_global_variables ',' TK_IDENTIFICADOR
    ;

command_block
    : '{' l_commands '}' { $$ = $2; }
    | '{' '}'  { $$ = NULL; }
    ;

l_commands
    : command ';' { $$ = $1; }
    | l_commands command ';' { $$ = $1; asd_append_next($$, $2); }
    ;

command
    : local_variables_declaration { $$ = $1; }
    | attribuition { $$ = $1; }
    | control_flow { $$ = $1; }
    | return_operation { $$ = $1; }
    | command_block { $$ = $1; }
    | function_call { $$ = $1; }
    ;

local_variables_declaration
    : type l_local_variables { $$ = $2; }

l_local_variables
    : TK_IDENTIFICADOR  { $$ = NULL; }
    | TK_IDENTIFICADOR TK_OC_LE literal { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | l_local_variables ',' TK_IDENTIFICADOR  { $$ = $1; }
    | l_local_variables ',' TK_IDENTIFICADOR TK_OC_LE literal { 
        if ($1 == NULL) { $$ = $4; asd_add_child($4, $3); asd_add_child($4, $5); }
        else { $$ = $1; asd_append_next($$, $4); asd_add_child($4, $3); asd_add_child($4, $5); } 
    }
    ;

attribuition
    : TK_IDENTIFICADOR '=' expression { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    ;

control_flow
    : if_statement { $$ = $1; }
    | while_statement { $$ = $1; }
    ;

if_statement
    : TK_PR_IF '(' expression ')' command_block { $$ = $1; asd_add_child($$, $3);  asd_add_child($$, $5);}
    | TK_PR_IF '(' expression ')' command_block TK_PR_ELSE command_block { $$ = $1;  asd_add_child($$, $3); asd_add_child($$, $5); asd_add_child($$, $7);}
    ;

while_statement
    : TK_PR_WHILE '(' expression ')' command_block { $$ = $1; asd_add_child($$, $3); asd_add_child($$, $5); }
    ;

return_operation
    : TK_PR_RETURN expression { $$ = $1; asd_add_child($$, $2); }

function_call
    : TK_IDENTIFICADOR '(' l_args ')' {
        char concatString[5 + strlen($1->label) + 1]; strcpy(concatString, "call "); strcat(concatString, $1->label);
        $$ = asd_new(concatString); asd_add_child($$, $3); 
    }
    | TK_IDENTIFICADOR '(' ')' {
        char concatString[5 + strlen($1->label) + 1]; strcpy(concatString, "call "); strcat(concatString, $1->label);
        $$ = asd_new(concatString);
    }
    ;

l_args
    : expression { $$ = $1; }
    | l_args ',' expression { $$ = $1; asd_append_next($$, $3); }
    ;

expression 
    : or_expression { $$ = $1; }
    ;

or_expression
    : or_expression TK_OC_OR and_expression  { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | and_expression { $$ = $1; }

and_expression
    : and_expression TK_OC_AND equality_expression { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | equality_expression { $$ = $1; }
    ;

equality_expression
    : equality_expression TK_OC_EQ relational_expression { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | equality_expression TK_OC_NE relational_expression { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | relational_expression { $$ = $1; }
    ;

relational_expression
    : relational_expression '<' additive_expression { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | relational_expression '>' additive_expression { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | relational_expression TK_OC_LE additive_expression { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | relational_expression TK_OC_GE additive_expression { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | additive_expression { $$ = $1; }
    ;

additive_expression
    : additive_expression '+' multiplicative_expression { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | additive_expression '-' multiplicative_expression { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | multiplicative_expression { $$ = $1; }
    ;

multiplicative_expression
    : multiplicative_expression '*' unary_expression { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | multiplicative_expression '/' unary_expression { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | multiplicative_expression '%' unary_expression { $$ = $2; asd_add_child($$, $1); asd_add_child($$, $3); }
    | unary_expression { $$ = $1; }
    ;

unary_expression
    : '-' operand { $$ = $1; asd_add_child($$, $2); }
    | '!' operand { $$ = $1; asd_add_child($$, $2); }
    | operand { $$ = $1; }
    ;

operand
    : '(' expression ')' { $$ = $2; }
    | TK_IDENTIFICADOR { $$ = $1; }
    | literal { $$ = $1; }
    | function_call { $$ = $1; }
    ;

type
    : TK_PR_INT { $$ = $1; }
    | TK_PR_FLOAT { $$ = $1; }
    | TK_PR_BOOL { $$ = $1; }
    ;

literal
    : TK_LIT_INT { $$ = $1; }
    | TK_LIT_FLOAT { $$ = $1; }
    | TK_LIT_FALSE { $$ = $1; }
    | TK_LIT_TRUE { $$ = $1; }
    ;

%%

void yyerror(char const *s) {
  printf("[%d]: %s\n", get_line_number(), s);
}
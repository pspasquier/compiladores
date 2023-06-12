%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
int yyerror (char const *s);
extern int get_line_number();

%}

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
    : global_declarations
    ;

global_declarations
    : function_declaration
    | global_variable_declaration
    | global_declarations function_declaration
    | global_declarations global_variable_declaration
    ;

function_declaration
    : TK_IDENTIFICADOR '(' l_params ')' TK_OC_MAP type command_block
    | TK_IDENTIFICADOR '(' ')' TK_OC_MAP type command_block
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
    : '{' l_commands '}'
    | '{' '}'
    ;

l_commands
    : command ';'
    | l_commands command ';'
    ;

command
    : local_variables_declaration
    | attribuition
    | control_flow
    | return_operation
    | command_block
    | function_call
    ;

local_variables_declaration
    : type l_local_variables

l_local_variables
    : TK_IDENTIFICADOR
    | TK_IDENTIFICADOR '=' expression
    | l_local_variables ',' TK_IDENTIFICADOR
    | l_local_variables ',' TK_IDENTIFICADOR '=' expression
    ;

attribuition
    : TK_IDENTIFICADOR '=' expression
    ;

control_flow
    : if_statement
    | if_statement else_statement
    | while_statement
    ;

if_statement
    : TK_PR_IF '(' expression ')' command_block
    ;

else_statement
    : TK_PR_ELSE command_block
    ;

while_statement
    : TK_PR_WHILE '(' expression ')'
    | TK_PR_WHILE '(' expression ')' command_block
    ;

return_operation
    : TK_PR_RETURN expression

function_call
    : TK_IDENTIFICADOR '(' l_args ')'
    | TK_IDENTIFICADOR '(' ')'
    ;

l_args
    : expression
    | l_args ',' expression
    ;

expression 
    : or_expression
    ;

or_expression
    : or_expression TK_OC_OR and_expression
    | and_expression

and_expression
    : and_expression TK_OC_AND equality_expression
    | equality_expression
    ;

equality_expression
    : equality_expression TK_OC_EQ relational_expression
    | equality_expression TK_OC_NE relational_expression
    | relational_expression
    ;

relational_expression
    : relational_expression '<' additive_expression
    | relational_expression '>' additive_expression
    | relational_expression TK_OC_LE additive_expression
    | relational_expression TK_OC_GE additive_expression
    | additive_expression
    ;

additive_expression
    : additive_expression '+' multiplicative_expression
    | additive_expression '-' multiplicative_expression
    | multiplicative_expression
    ;

multiplicative_expression
    : multiplicative_expression '*' unary_expression
    | multiplicative_expression '/' unary_expression
    | multiplicative_expression '%' unary_expression
    | unary_expression
    ;

unary_expression
    : '-' operand
    | '!' operand
    | operand
    ;

operand
    : '(' expression ')'
    | TK_IDENTIFICADOR
    | literal
    | function_call
    ;

type
    : TK_PR_INT
    | TK_PR_FLOAT
    | TK_PR_BOOL
    ;

literal
    : TK_LIT_INT
    | TK_LIT_FLOAT
    | TK_LIT_FALSE
    | TK_LIT_TRUE
    ;

%%

int yyerror(char const *s) {
  printf("[%d]: %s\n", get_line_number(), s);
}
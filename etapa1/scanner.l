%{
#include "tokens.h"

int get_line_number()
{
    return yylineno;
}
%}
%option yylineno

DIGITS [0-9]
ESPECIAIS  [-!*/%+<>{}()=,;]
IDENTIFIER_CHARACTERS [a-z_]
IGNORED_BUNCH [ \n]

%s ML_COMMENT

%%

<ML_COMMENT>{
    "*/"      { BEGIN(INITIAL); }
    .|\n      { /* Ignore other characters within the comment */ }
}

<INITIAL>{
	"/*"	{BEGIN(ML_COMMENT);}
	{IGNORED_BUNCH}  	{}
	"//"[^\n]* 		{}
	"<=" return TK_OC_LE;
	">=" return TK_OC_GE;
	"==" return TK_OC_EQ;
	"!="  return TK_OC_NE;
	"&"  return TK_OC_AND;
	"|"  return TK_OC_OR;
	"->"  return TK_OC_MAP;
	int return TK_PR_INT;
	float return TK_PR_FLOAT;
	bool return TK_PR_BOOL;
	if return TK_PR_IF;
	else return TK_PR_ELSE;
	while return TK_PR_WHILE;
	return return TK_PR_RETURN;
	true return TK_LIT_FALSE;
	false return TK_LIT_TRUE;
	{DIGITS}*"."{DIGITS}+ return TK_LIT_FLOAT;
	{DIGITS}+ return TK_LIT_INT;
	{ESPECIAIS} {return yytext[0];}
	{IDENTIFIER_CHARACTERS}+ return TK_IDENTIFICADOR; 
}
.  return TK_ERRO;

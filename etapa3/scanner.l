%{
#include "parser.tab.h"

int get_line_number()
{
    return yylineno;
}

void set_lexical_value(const char* yytext, token_type_t type)
{
	yylval.lexical_value.label = strdup(yytext);
	yylval.lexical_value.line = get_line_number();
	yylval.lexical_value.type = type;
}

%}
%option yylineno

DIGITS [0-9]
SPECIALS  [-!*/%+<>{}()=,;]
IDENTIFIER_CHARACTERS [a-z_]
IGNORED_BUNCH [ \n\t]

%s ML_COMMENT

%%

<ML_COMMENT>{
    "*/"      { BEGIN(INITIAL); }
    .|\n      { /* Ignore other characters within the comment */ }
}

<INITIAL>{
	"/*"	{ BEGIN(ML_COMMENT); }
	{IGNORED_BUNCH}  	{}
	"//"[^\n]* 		{}
	"<=" { set_lexical_value(yytext, COMPOUND_OPERATOR); return TK_OC_LE; }
	">=" { set_lexical_value(yytext, COMPOUND_OPERATOR); return TK_OC_GE; }
	"==" { set_lexical_value(yytext, COMPOUND_OPERATOR); return TK_OC_EQ; }
	"!=" { set_lexical_value(yytext, COMPOUND_OPERATOR); return TK_OC_NE; }
	"&" { set_lexical_value(yytext, COMPOUND_OPERATOR); return TK_OC_AND; }
	"|" { set_lexical_value(yytext, COMPOUND_OPERATOR); return TK_OC_OR; }
	"->" { set_lexical_value(yytext, COMPOUND_OPERATOR); return TK_OC_MAP; }
	int { set_lexical_value(yytext, RESERVERD_WORD); return TK_PR_INT; }
	float { set_lexical_value(yytext, RESERVERD_WORD); return TK_PR_FLOAT; }
	bool { set_lexical_value(yytext, RESERVERD_WORD); return TK_PR_BOOL; }
	if { set_lexical_value(yytext, RESERVERD_WORD); return TK_PR_IF; }
	else { set_lexical_value(yytext, RESERVERD_WORD); return TK_PR_ELSE; }
	while { set_lexical_value(yytext, RESERVERD_WORD); return TK_PR_WHILE; }
	return { set_lexical_value(yytext, RESERVERD_WORD); return TK_PR_RETURN; }
	true { set_lexical_value(yytext, LITERAL); return TK_LIT_TRUE; }
	false { set_lexical_value(yytext, LITERAL); return TK_LIT_FALSE; }
	{DIGITS}*"."{DIGITS}+ { set_lexical_value(yytext, LITERAL); return TK_LIT_FLOAT; }
	{DIGITS}+ { set_lexical_value(yytext, LITERAL); return TK_LIT_INT; }
	{SPECIALS} { set_lexical_value(yytext, SPECIAL); return yytext[0]; }
	{IDENTIFIER_CHARACTERS}+ { set_lexical_value(yytext, IDENTIFIER); return TK_IDENTIFICADOR; }
}
.  return TK_ERRO;

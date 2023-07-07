%{
#include "parser.tab.h"

int get_line_number()
{
    return yylineno;
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
	"/*"	{BEGIN(ML_COMMENT);}
	{IGNORED_BUNCH}  	{}
	"//"[^\n]* 		{}
	"<=" { yylval = asd_new(yytext); return TK_OC_LE; }
	">=" { yylval = asd_new(yytext); return TK_OC_GE; }
	"==" { yylval = asd_new(yytext); return TK_OC_EQ; }
	"!=" { yylval = asd_new(yytext); return TK_OC_NE; }
	"&"  { yylval = asd_new(yytext); return TK_OC_AND; }
	"|"  { yylval = asd_new(yytext); return TK_OC_OR; }
	"->" { yylval = asd_new(yytext); return TK_OC_MAP; }
	int { return TK_PR_INT; }
	float { return TK_PR_FLOAT; }
	bool { return TK_PR_BOOL; }
	if { yylval = asd_new(yytext); return TK_PR_IF; }
	else { yylval = asd_new(yytext); return TK_PR_ELSE; }
	while { yylval = asd_new(yytext); return TK_PR_WHILE; }
	return { yylval = asd_new(yytext); return TK_PR_RETURN; }
	true { yylval = asd_new(yytext); return TK_LIT_TRUE; }
	false { yylval = asd_new(yytext); return TK_LIT_FALSE; }
	{DIGITS}*"."{DIGITS}+ { yylval = asd_new(yytext); return TK_LIT_FLOAT; }
	{DIGITS}+ { yylval = asd_new(yytext); return TK_LIT_INT; }
	{SPECIALS} { yylval = asd_new(yytext); return yytext[0]; }
	{IDENTIFIER_CHARACTERS}+ { yylval = asd_new(yytext); return TK_IDENTIFICADOR; }
}
.  return TK_ERRO;

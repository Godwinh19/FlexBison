/* Ce programme d'un grafcet retourne le nombre d'etapes, de transitions, de conditions,de commentaires et d'identifiant pour un code d'un système entré au clavier. */

%{

int nbTransitions, nbSteps, nbConditions, nbComments, nbId, init;
extern int lineNumber;

void yyerror(const char * msg);
#include "progY.hpp"

%}
%option noyywrap
letter		[A-Za-z]
digit		[0-9]
sep		[' ']
ws		[\n\t' ']
op		"=="|"<"|">"|"<="|">="
operator	[+-/*]
boolean		[01]
entier		{digit}+	
name		[A-Za-z][_A-Za-z0-9]*
many_name	(:{name})+
var		{entier}+
text		({name}[' ']*)+
cond		{name}=={var}|{name}<{var}|{name}>{var}|{name}<={var}|{name}>={var}
condition	["C"]{sep}{name}{sep}{cond};|["C"]{sep}{name}{sep}{boolean};
action		["A"]{sep}{name}={entier};|["A"]{sep}{name}={name}{operator}{var};
step		["S"]{sep}{letter}{digit}+(({sep}{action})+|;)
transition	["go("]{name},{name},{name}[")"];|["go("]{name},({name},)+{name}[")"];
comment         ["#"]{sep}{text}|["#"]{text}
sleep		["wait("]{entier}[")"];
closure		"START\n"|"END\n"
ponctuation	[,;:?!\.]

%%
"START"		{ return(START); }
"END"		{ return(END); }
"="		{ sprintf(yylval.str, "%s", yytext);return(EQUAL); }
","		{ return(COMMA); }
":"		{ return(COLON); }
";"		{ return(SEMICOLON); }
"go"		{ return(GO); }
"S"		{ return(S); }
"S0"		{ return(S0); }
"C"		{ return(C); }
"A"		{ return(A); }
"T"		{ return(T); }
"wait"		{ return(WAIT); }
"("		{ return(OPEN); }
")"		{ return(CLOSE); }
{op}		{ sprintf(yylval.str, "%s", yytext);return(OP); }
{operator}	{ sprintf(yylval.str, "%s", yytext);return(OPERATOR); }
{var}		{ sprintf(yylval.str, "%s", yytext);return(VARIABLE); }
{sep}		{ return(WS); }
{many_name}	{ sprintf(yylval.str, "%s", yytext);return(MANYNAME); }
{name}		{ sprintf(yylval.str, "%s", yytext);return(NAME); }
{comment}	{ return(COMMENT); }
"\n"		{ ++lineNumber; }
"\t"		{ /* rien */ }
.          	{ char msg[0x20]; sprintf(msg,"lexical error <%s>",yytext); yyerror(msg); }

%%


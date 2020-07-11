%{
#include <stdio.h>
#include <iostream>
using namespace std;

int yylex(void);
void yyerror(const char * msg);

int lineNumber, nT, nE, nC, nI, nCo, nS;
extern FILE * yyin;
%}

%token START END
%token TRANSITION CONDITION IDENT
%token COMMENT
%token GO OPEN CLOSE MANYNAME NAME OP WAIT
%token EQUAL SEMICOLON COMMA WS COLON OPERATOR
%token S A C T S0 VARIABLE
%union { char str[0x255]; double real; int integer; }
%type<str> IDENT expr NAME trans GO COMMA SEMICOLON MANYNAME OPEN CLOSE EQUAL
%type<str> VARIABLE OP OPERATOR
%left OP EQUAL

%start program   //l'axiome de ma grammaire
%%
program : START etat bloc END { cerr << "program" << endl; }
;
bloc : bloc inst
	 | inst
;
inst : expr { cerr <<" " << endl; }
;
expr : trans { ++nT ; cerr <<"transition° " << nT << endl; }
     | etat { ++nE ; cerr <<"etape n° " << nE << endl; }
     | condition { ++nC ; cerr <<"condition n°" << nC << endl; }
     | IDENT { ++nI ; cerr <<"identifiant " << $1 << endl; sprintf($$, "s:%s", $1); }
     | COMMENT { ++nCo ; cerr <<"commentaire" << endl; }
     | sleep { ++nS ; cerr <<"sleep" << endl; }
;
trans : T WS NAME COLON WS GO OPEN NAME COMMA NAME COMMA NAME CLOSE SEMICOLON { cerr <<"Nom transition " << $3 <<" Etape d'entre: " << $8 << "  Etape de sortie " << $10 << " Condition "<< $12 << endl;}
      | T WS NAME COLON WS GO OPEN NAME COMMA MANYNAME COMMA NAME CLOSE SEMICOLON { cerr <<"Nom transition " << $3 <<" Etape d'entre: " << $8 << "  Etape de sortie " << $10 << " Condition "<< $12 << endl;}
      | T WS NAME COLON WS GO OPEN MANYNAME COMMA MANYNAME COMMA NAME CLOSE SEMICOLON { cerr <<"Nom transition " << $3 <<" Etapes d'entres: " << $8 << "  Etape de sortie " << $10 << " Condition "<< $12 << endl;}
      | T WS NAME COLON WS GO OPEN MANYNAME COMMA NAME COMMA NAME CLOSE SEMICOLON { cerr <<"Nom transition " << $3 <<" Etape d'entre: " << $8 << "  Etape de sortie " << $10 << " Condition "<< $12 << endl;}
;
condition : C WS NAME WS NAME OP VARIABLE SEMICOLON  { cerr << "\t>>Nom condition: "<< $3 << " action: " << $5 << $6 << $7 <<endl;}
	  | C WS VARIABLE SEMICOLON	{ cerr << "\t>>Condition booleenne " <<endl;}
; 
etat : S0 WS NAME SEMICOLON { cerr <<"Nom etat: " << $3 << " Étape initiale " << endl; }
     | S WS NAME SEMICOLON { cerr <<"\t>>Nom etat: " << $3 << endl; }
     | S WS NAME WS action SEMICOLON { cerr <<"\t>>Nom etat: " << $3 << endl; }
;
action: A WS NAME EQUAL VARIABLE { cerr << "\t>>Action: " << $3 << $4 << $5 <<endl; }
      | A WS NAME EQUAL NAME OPERATOR VARIABLE { cerr << "\t>>Action: " << $3 << $4 << $5 << $6 << $7 <<endl;}
      | A WS VARIABLE { cerr <<" Action Boolean" <<endl; }
;
sleep : WAIT OPEN VARIABLE CLOSE SEMICOLON
;
%%
void yyerror(const char * msg)
{
cerr << "ligne " << lineNumber << ": " << msg << endl;
}
int main(int argc,char ** argv)
{
if(argc>1) yyin=fopen(argv[1],"r"); // verification du code
lineNumber=1;
nT=0; nE=0; nC=0; nI=0; nCo=0; nS=0;
if(!yyparse()) cerr << "Success\n_____________________________________________________________________\n\t\t\t\tStatistiques\n\tEtapes:\tTransitions:\tConditions:\tCommentaires: \tIdentifiants:\tSleep\t\n\t  " << nE << "\t  " << nT << "\t\t  " << nC << "\t\t  " << nCo << "\t\t  " << nI << "\t\t" << nS << endl;
return(0);
}

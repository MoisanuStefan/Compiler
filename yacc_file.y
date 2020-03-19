%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "tema.h"

extern FILE* yyin;
extern char* yytext;
extern int yylineno;
extern char* yytext;
char defaultValue[] = "not_a_string";

%}
%union {
    int intVal;
    char* dataType;
    char* strVal;
    char *key;
}

%token  BEG END ANS  EVAL WHILE FOR IF ELSE BOOLEQ BOOLGEQ BOOLLEQ BOOLNEQ LOGICALAND LOGICALOR  DECLF FCALL RETURN  BOOLGE BOOLLE EQ OBJCALL CONCAT
%token <strVal> INTTYPE BOOLTYPE STRINGTYPE ARRAYTYPE OBJTYPE CHARTYPE VOID STRINGVAL CHARVAL TRUE FALSE ID
%token <intVal> NR
%token <key>  DECL ODECL

%type <intVal> exp e
%type <intVal> minus plus mul div operatie
%type <strVal> string_sum

%start start
%left PLUS MINUS
%left MUL DIV
%%

start				: program {printf ("The program is syntactically correct.\n"); PrintTable();};

program				: declarations functions
;

declarations 			: objects
|
;

objects 			: objects object
| object
;

go_deeper 			: { GoDeeper(); }
;

end	    			: END { GoHigher(); }
;

object 				: obj_declr obj_body

obj_declr: OBJCALL OBJTYPE ID {UpdateVarTable(-1,$2,$3,-1,defaultValue);}
;

obj_body: go_deeper BEG  atribute_list end
| go_deeper BEG end
;

atribute_list 			: atribute_list atribute
| atribute
;

atribute 			: DECL INTTYPE ID EQ NR'.' 		{UpdateVarTable(1,$2,$3,$5,defaultValue);}
| DECL INTTYPE ID'.'      		{UpdateVarTable(1, $2, $3, 2000000000,defaultValue);}
| DECL CHARTYPE ID  EQ CHARVAL '.'	{UpdateVarTable(1, $2, $3, -1,$5);}
| DECL CHARTYPE ID'.'        		{UpdateVarTable(1, $2, $3, -1,defaultValue);}
| DECL STRINGTYPE ID  EQ STRINGVAL '.'	{UpdateVarTable(1, $2, $3, -1,$5);}
| DECL STRINGTYPE ID'.'			{UpdateVarTable(1, $2, $3, -1,defaultValue);}
| DECL BOOLTYPE ID EQ TRUE'.'		{UpdateVarTable(1, $2, $3, 1,$5);}
| DECL BOOLTYPE ID EQ FALSE'.'		{UpdateVarTable(1, $2, $3, 0,$5);}
| DECL BOOLTYPE ID'.'			{UpdateVarTable(1,$2,$3,-1,defaultValue);}
| DECL ARRAYTYPE ID EQ arraylist'.'	{UpdateVarTable(1, $2, $3, -1,defaultValue);}
| FCALL  EVAL '(' exp ')'
| FCALL ID '(' call_arguments ')'       {CheckFunctionCall($2);}
| ODECL INTTYPE ID EQ NR'.' 		{UpdateVarTable(0, $2, $3, $5,defaultValue);}
| ODECL INTTYPE ID'.'			{UpdateVarTable(0, $2, $3, 2000000000,defaultValue);}
| ODECL CHARTYPE ID  EQ CHARVAL '.'	{UpdateVarTable(0, $2, $3, -1, $5);}
| ODECL CHARTYPE ID'.'			{UpdateVarTable(0, $2, $3, -1, defaultValue);}
| ODECL STRINGTYPE ID  EQ STRINGVAL '.'	{UpdateVarTable(0, $2, $3, -1, $5);}
| ODECL STRINGTYPE ID'.'		{UpdateVarTable(0, $2, $3, -1, defaultValue);}
| ODECL BOOLTYPE ID EQ TRUE'.'		{UpdateVarTable(0, $2, $3, 1,$5);}
| ODECL BOOLTYPE ID EQ FALSE'.'		{UpdateVarTable(0, $2, $3, 0,$5);}
| ODECL BOOLTYPE ID'.' 			{UpdateVarTable(0,$2,$3,-1,defaultValue);}
| ODECL ARRAYTYPE ID EQ arraylist'.'	{UpdateVarTable(0, $2, $3, -1,defaultValue);}
| ODECL INTTYPE EVAL '(' exp ')'
;

arraylist 			: '['']'
| '['list']'
;

list 				: list',' listval
| listval
;

listval 			: NR
| CHARVAL
| STRINGVAL
| ID
| object
| arraylist
;

functions 			: functions  function
| function
;

function 			: DECLF INTTYPE ID    go_deeper function_body { ConstructSignature($2); ConstructSignature($3); UpdateFctTable();}
| DECLF CHARTYPE ID   go_deeper function_body { ConstructSignature($2); ConstructSignature($3); UpdateFctTable();}
| DECLF VOID ID       go_deeper function_body { ConstructSignature($2); ConstructSignature($3); UpdateFctTable();}
| DECLF BOOLTYPE ID   go_deeper function_body { ConstructSignature($2); ConstructSignature($3); UpdateFctTable();}
| DECLF STRINGTYPE ID go_deeper function_body { ConstructSignature($2); ConstructSignature($3); UpdateFctTable();}
| DECLF INTTYPE EVAL '(' exp ')'
| FCALL ID '(' call_arguments')'    {CheckFunctionCall($2);}
;

function_body   			: '(' arguments ')' body
;

call_arguments    		: call_arguments ',' call_argument
| call_argument
;

call_argument     		: INTTYPE ID
| CHARTYPE ID
| STRINGTYPE ID
| BOOLTYPE ID
| function
| NR
;

arguments    		: arguments ',' argument
| argument
;

argument     		: INTTYPE ID    {  ConstructArgumentList($1);}
| CHARTYPE ID   {  ConstructArgumentList($1);}
| STRINGTYPE ID {  ConstructArgumentList($1);}
| BOOLTYPE ID   {  ConstructArgumentList($1);}
;


exp       			: e  {$$=$1; printf("Value of expression: %d\n",$$);}
;

e 				: e PLUS e   {$$=$1+$3; }
| e MINUS e   {$$=$1-$3; }
| e MUL e   {$$=$1*$3; }
| e DIV e   {$$=$1/$3; }
| NR {$$=$1; }
| DECL INTTYPE ID EQ NR'.' { $$ = FindAndUpdateFuncMember($3, $5);}
| DECL INTTYPE ID'.' { $$ = FindFuncMember($3);}
;

body      			: BEG blockInstructions RETURN end
| BEG blockInstructions end
| BEG END
;


blockInstructions   		: blockInstructions blockInstruction
| blockInstruction
;

blockInstruction    		: atribute
| assignment
| while
| for
| if
;

while 				: WHILE go_deeper '(' conditii ')' body
;

for  				: FOR go_deeper '(' assignment conditii '.' assignment ')' body
;

if   				: IF go_deeper '(' conditii ')' body
| IF go_deeper '(' conditii ')' body ELSE go_deeper body
;

assignment 			: DECL ID EQ NR'.' { UpdateInt($2, $4); }
| DECL ID EQ CHARVAL'.' {UpdateChar($2, $4); }
| DECL ID EQ STRINGVAL'.' {UpdateString($2, $4); }
| DECL ID EQ TRUE'.'    {UpdateBool($2, $4); }
| DECL ID EQ FALSE'.'   {UpdateBool($2, $4); }
| DECL ID EQ arraylist'.'
| DECL ID EQ operatie'.' {UpdateInt($2,$4);}
| DECL ID EQ string_sum'.' {UpdateString($2,$4);}
| DECL ID EQ ID'.' { UpdateVar($2, $4); }
;

operatie  			: plus{$$=$1;}
| minus{$$=$1;}
| mul{$$=$1;}
| div{$$=$1;}
;

string_sum: ID CONCAT ID {
    if(CheckStringInit($1)==0 && CheckStringInit($3)==0) 
        $$=myStrcat(strdup(GetStringVal($1)),strdup(GetStringVal($3)));
    else
        printf("Cannot compile!\n");
}
| ID CONCAT STRINGVAL {
    if(CheckStringInit($1)==0) 
        $$=myStrcat(strdup(GetStringVal($1)),strdup($3));
    else
        printf("Cannot compile!\n");
}
|STRINGVAL CONCAT ID {
    if(CheckStringInit($3)==0) 
        $$=myStrcat(strdup($1),strdup(GetStringVal($3)));
    else
        printf("Cannot compile!\n");
}
;

plus 				: ID PLUS ID {
    if(CheckIntInit($1)==0 && CheckIntInit($3)==0) 
        $$=GetIntVal($1)+GetIntVal($3);
    else
        printf("Cannot compile!\n");
}
| ID PLUS NR {
    if(CheckIntInit($1)==0) 
        $$=GetIntVal($1)+$3;
    else
        printf("Cannot compile!\n");
}
| NR PLUS ID {
    if(CheckIntInit($3)==0) 
        $$=$1+GetIntVal($3);
    else
        printf("Cannot compile!\n");
}
;

minus				: ID MINUS ID {
    if(CheckIntInit($1)==0 && CheckIntInit($3)==0) 
        $$=GetIntVal($1)-GetIntVal($3);
    else
        printf("Cannot compile!\n");
}
| ID MINUS NR {
    if(CheckIntInit($1)==0) 
        $$=GetIntVal($1)-$3;
    else
        printf("Cannot compile!\n");
}
| NR MINUS ID {
    if(CheckIntInit($3)==0) 
        $$=$1-GetIntVal($3);
    else
        printf("Cannot compile!\n");
}
;

mul  				: ID MUL ID {
    if(CheckIntInit($1)==0 && CheckIntInit($3)==0) 
        $$=GetIntVal($1)*GetIntVal($3);
    else
        printf("Cannot compile!\n");
}
| ID MUL NR {
    if(CheckIntInit($1)==0) 
        $$=GetIntVal($1)*$3;
    else
        printf("Cannot compile!\n");
}
| NR MUL ID {
    if(CheckIntInit($3)==0) 
        $$=$1*GetIntVal($3);
    else
        printf("Cannot compile!\n");
}
;

div  				: ID DIV ID {
    if(CheckIntInit($1)==0 && CheckIntInit($3)==0) 
        $$=GetIntVal($1)/GetIntVal($3);
    else
        printf("Cannot compile!\n");
}
| ID DIV NR {
    if(CheckIntInit($1)==0) 
        $$=GetIntVal($1)/$3;
    else
        printf("Cannot compile!\n");
}
| NR DIV ID {
    if(CheckIntInit($3)==0) 
        $$=$1/GetIntVal($3);
    else
        printf("Cannot compile!\n");
}
;

conditii  			: conditii logicalOp conditie
| conditie
;

logicalOp 			: LOGICALAND
| LOGICALOR
;

conditie 			: TRUE
| FALSE
| NR boolOp NR
| ID boolOp NR
| NR boolOp ID
| ID boolOp ID
;

boolOp  			: BOOLEQ
| BOOLGEQ
| BOOLLEQ
| BOOLNEQ
| BOOLLE
| BOOLGE
;


%%

int yyerror(char * s){
    printf("Eroare: %s la linia:%d iar yytext este %s\n",s,yylineno,yytext);
}

int main(int argc, char** argv){
    yyin=fopen(argv[1],"r");
    yyparse();
}

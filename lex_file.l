%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%
"/*"(.|\n|\r)+"*/" ;

"==" {return BOOLEQ;}
"!=" {return BOOLEQ;}
"<=" {return BOOLLEQ;}
">=" {return BOOLGEQ;}
">" {return BOOLGE;}
"<" {return BOOLLE;}

"=" {return EQ;}
"+" {return PLUS;}
"-" {return MINUS;}
"/" {return DIV;}
"*" {return MUL;}

"&&" {return LOGICALAND;}
"||" {return LOGICALOR;}

"function_member" {yylval.key = strdup(yytext);return DECL;}
"attribute" {yylval.key = strdup(yytext);return ODECL;}
"<function>" {return DECLF;}
"<function_call>" {return FCALL;}
"<class>" {return OBJCALL;}


"Eval"      {return EVAL;}
"int"        {yylval.strVal = strdup(yytext);return INTTYPE;} 
"char"       {yylval.strVal = strdup(yytext);return CHARTYPE;}
"string"        {yylval.strVal = strdup(yytext);return STRINGTYPE;}
"void"      {yylval.strVal = strdup(yytext);return VOID;}  
"bool"     {yylval.strVal = strdup(yytext);return BOOLTYPE;}
"array"                 {yylval.strVal = strdup(yytext);return ARRAYTYPE;}
"object"                  {yylval.strVal = strdup(yytext);return OBJTYPE;}
"{"                    {return BEG;}
"}"   {return END;}
"concat" {return CONCAT;}
"return" {return RETURN;}
"true"  {yylval.strVal = strdup(yytext);return TRUE;}
"false"   {yylval.strVal = strdup(yytext);return FALSE;}
"while" {return WHILE;}
"for" {return FOR;}
"if" {return IF;}
"else" {return ELSE;}
\'.\' {yylval.strVal = strdup(yytext); return CHARVAL;}
\"[^\"]+\" {yylval.strVal = strdup(yytext); return STRINGVAL;}
[A-Za-z][A-Za-z0-9]* {yylval.strVal = strdup(yytext);return ID;}
0|[1-9][0-9]*|[+-][1-9][0-9]* {yylval.intVal = atoi(yytext);return NR;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

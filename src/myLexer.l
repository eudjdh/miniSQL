%{
    #include "parser.tab.h"
%}

char [a-zA-Z]
digit [0-9]+
digits {digit}+

%option caseless

%%

"create"                            {return KW_CREATE;}
"databases"                         {return KW_DATABASES;}
"database"                          {return KW_DATABASE;}
"show"                              {return KW_SHOW;}
"tables"                            {return KW_TABLES;}
"table"                             {return KW_TABLE;}
"use"                               {return KW_USE;}
"insert"                            {return KW_INSERT;}
"drop"                              {return KW_DROP;}
"into"                              {return KW_INTO;}
"values"                            {return KW_VALUES;}
"select"                            {return KW_SELECT;}
"from"                              {return KW_FROM;}
"where"                             {return KW_WHERE;}
"and"                               {return KW_AND;}
"or"                                {return KW_OR;}
"delete"                            {return KW_DELETE;}
"update"                            {return KW_UPDATE;}
"int"                               {return KW_INT;}
"char"                              {return KW_CHAR;}
"set"                               {return KW_SET;}
"("                                 {return '(';}
")"                                 {return ')';}
"*"                                 {return STAR;}
";"                                 {return ';';}
","                                 {return ',';}
"="                                 {return '=';}
">="                                {return GREATER_OR_EQUAL;}
"<="                                {return LESS_OR_EQUAL;}
"<>"                                {return NOT_EQUAL;}
">"                                 {return '>';}
"<"                                 {return '<';}
"!="                                {return NOT_EQUAL;}
"'"                                 {return SINGLE_QUOTE;}
"exit"                              {return EXIT;}
({char}|"_")({char}|{digit}|"_")*   {yylval.str_val = strdup(yytext); return IDENTIFIER;}
{digits}("."{digits})?              {yylval.str_val = strdup(yytext); return NUMBER;}
[ \r\t\n]+                          ;
.                                   {return UNKNOWN;}

%%


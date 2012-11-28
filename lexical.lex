%option noyywrap
%option case-insensitive
%option yylineno
%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "syntax.tab.h"
  #define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;

  void string_function(char *s);
  static char array[1000];
  static int i=0;
  static int error=0;
  static char *line;
  void char_function(char s);
  void bintodec_function(char *s);
  void bintodec_function2(char*s);
  void octtodec_function(char *s);
  void yyerror(char *s);
%}

ALPHAS [A-Za-z]
DIGITS	[0-9]
IDRULE1 {ALPHAS}+{DIGITS}*{ALPHAS}*{DIGITS}*
IDRULE2 [_]{IDRULE1}([_]{IDRULE1})*[_]
RCONSTRULE (E[-+]*[1-9]+[0-9]*)*
CCONSTRULE \\n|\\t|\\f|\\r|\\v|\\b
WHITESPACES	[ \t]

%x STRINGS
%x PARSE
%%

.*\n			{ line=strdup(yytext); yyless(0); BEGIN(PARSE);}

<PARSE>
{
  \n {BEGIN(INITIAL);}

 $.+$|$.+\n			{
 #ifdef DEBUG
 printf("Found COMMENTS\n");
 #endif 
 BEGIN(INITIAL);

 }


		    
 "0" 				{printf("Found ICONST\n"); yylval.iconst=0;  printf("%d\n",yylval.iconst);  return(ICONST);}
 [1-9]+[0-9]*			{printf("Found ICONST\n"); yylval.iconst=atoll(yytext); printf("%d\n",yylval.iconst); return(ICONST);}
 "0H"[1-9A-F]+[0-9A-F]*		{printf("Found ICONST\n"); yytext[1] = 'x'; yylval.iconst=strtol(yytext,NULL,16); printf("%d\n",yylval.iconst);return(ICONST);}
 "0O"[1-7]+[0-7]*		{printf("Found ICONST\n"); yytext[1] = '0'; yylval.iconst=strtol(yytext,NULL,8);  printf("%d\n",yylval.iconst);return(ICONST);}
 "0B"[1]+[0-1]*			{printf("Found ICONST\n"); bintodec_function(yytext);       printf("%d\n",yylval.iconst); return(ICONST);}
		  
  "0."					{printf("Found RCONST\n"); yylval.rconst=atof(yytext); printf("%f\n",yylval.rconst); return(RCONST);}
  "."[0-9]*[1-9]+[0-9]*{RCONSTRULE}	{printf("Found RCONST\n"); yylval.rconst=atof(yytext); printf("%f\n",yylval.rconst); return(RCONST);}
 [1-9]+[0-9]*"."[1-9]*{RCONSTRULE}	{printf("Found RCONST\n"); yylval.rconst=atof(yytext); printf("%f\n",yylval.rconst); return(RCONST);}
[0-9]+"."[0-9]*[1-9]+[0-9]*{RCONSTRULE} {printf("Found RCONST\n"); yylval.rconst=atof(yytext); printf("%f\n",yylval.rconst); return(RCONST);}
([1-9]+[0-9]*){RCONSTRULE}		{printf("Found RCONST\n"); yylval.rconst=atof(yytext); printf("%f\n",yylval.rconst); return(RCONST);}
		  
"0H"[1-9A-F]+[0-9A-F]*"."[0-9A-F]*[1-9A-F]+[0-9A-F]*	{printf("Found RCONST\n"); yytext[1] = 'x'; yylval.rconst=strtold(yytext,NULL); printf("%f\n",yylval.rconst);return(RCONST);}
"0H"[1-9A-F]+[0-9A-F]*"."			{printf("Found RCONST\n"); yytext[1] = 'x'; yylval.rconst=strtold(yytext,NULL); 	printf("%f\n",yylval.rconst);return(RCONST);}
"0H"[0]"."[0-9A-F]*[1-9A-F]+[0-9A-F]*			{printf("Found RCONST\n"); yytext[1] = 'x'; yylval.rconst=strtold(yytext,NULL); printf("%f\n",yylval.rconst);return(RCONST);}
"0H""."[0-9A-F]*[1-9A-F]+[0-9A-F]*			{printf("Found RCONST\n"); yytext[1] = 'x'; yylval.rconst=strtold(yytext,NULL); printf("%f\n",yylval.rconst);return(RCONST);}		  
"0O"[1-7]+[0-7]*"."[0-7]*[1-7]+[0-7]*			{printf("Found RCONST\n"); octtodec_function(yytext); printf("%f\n",yylval.rconst);return(RCONST);}
"0O"[1-7]+[0-7]"."					{printf("Found RCONST\n"); octtodec_function(yytext); printf("%f\n",yylval.rconst);return(RCONST);}
"0O"[0]"."[0-7]*[1-7]+[0-7]*				{printf("Found RCONST\n"); octtodec_function(yytext); printf("%f\n",yylval.rconst);return(RCONST);}
"0O""."[0-7]*[1-7]+[0-7]*				{printf("Found RCONST\n"); octtodec_function(yytext); printf("%f\n",yylval.rconst);return(RCONST);}	    
"0B"[1]+[0-1]*"."[0-1]*[1]+[0-1]*			{printf("Found RCONST\n"); bintodec_function2(yytext); printf("%f\n",yylval.rconst); return(RCONST);}
"0B"[1]+[0-1]*"."					{printf("Found RCONST\n"); bintodec_function2(yytext); printf("%f\n",yylval.rconst); return(RCONST);}
"0B"[0]"."[0-1]*[1]+[0-1]*				{printf("Found RCONST\n"); bintodec_function2(yytext); printf("%f\n",yylval.rconst); return(RCONST);}
"0B""."[0-1]*[1]+[0-1]*				{printf("Found RCONST\n"); bintodec_function2(yytext); printf("%f\n",yylval.rconst); return(RCONST);}

".TRUE."	{printf("Found LCONST\n"); yylval.lconst=1; return(LCONST); }
".FALSE."	{printf("Found LCONST\n"); yylval.lconst=0; return(LCONST);}

\'.\'			{printf("Found CCONST\n"); yylval.cconst=yytext[1]; return(CCONST);}
\'{CCONSTRULE}\'	{printf("Found CCONST\n"); char_function(yytext[3]); return(CCONST);}



".OR."		{printf("Found OPERATOR\n"); return(OROP);}
".AND."		{printf("Found OPERATOR\n"); return(ANDOP);}
".NOT."		{printf("Found OPERATOR\n"); return(NOTOP);}
".GT."		{printf("Found OPERATOR\n"); yylval.relop=0; return(RELOP);}
".GE."		{printf("Found OPERATOR\n"); yylval.relop=1; return(RELOP);}
".LT."		{printf("Found OPERATOR\n"); yylval.relop=2; return(RELOP);}
".LE."		{printf("Found OPERATOR\n"); yylval.relop=3; return(RELOP);}
".EQ."		{printf("Found OPERATOR\n"); yylval.relop=4; return(RELOP);}
".NE."		{printf("Found OPERATOR\n"); yylval.relop=5; return(RELOP);}
"+"		{printf("Found OPERATOR\n"); yylval.addop_type=1; return(ADDOP);}
"-"		{printf("Found OPERATOR\n"); yylval.addop_type=0; return(ADDOP);}

"/"		{printf("Found OPERATOR\n"); return(DIVOP);}
"**"		{printf("Found OPERATOR\n"); return(POWEROP);}
"*"		{printf("Found OPERATOR\n"); return(MULOP);}

CAD*R	{printf("Found LISTFUNC\n");  
	  yylval.listfunc=(char *)malloc((yyleng + 1) * sizeof(char));
	  if(!yylval.listfunc){
	    printf("memory allocation error"); exit(0);
	  }
	  strcpy(yylval.listfunc, yytext);
	  return(LISTFUNC);}
CD+R	{printf("Found LISTFUNC\n"); 
	  yylval.listfunc=(char *)malloc((yyleng + 1) * sizeof(char));
	  if(!yylval.listfunc){
	    printf("memory allocation error"); exit(0);
	  }
	  strcpy(yylval.listfunc, yytext);
	  return(LISTFUNC);}

"("		{printf("Found LPAREN\n"); return(LPAREN);}
")"		{printf("Found RPAREN\n"); return(RPAREN);}
","		{printf("Found COMMA\n");  return(COMMA);}
":"		{printf("Found COLON\n");  return(COLON);}
"["		{printf("Found LBRACK\n"); return(LBRACK);}
"]"		{printf("Found RBRACK\n"); return(RBRACK);}
"="		{printf("Found ASSIGN\n"); return(ASSIGN);}

{WHITESPACES}	{printf("Found SPACE\n");}


"FUNCTION"	{printf("Found FUNCTION keyword\n"); 	return(FUNCTION);}
"SUBROUTINE" 	{printf("Found SUBROUTINE keyword\n"); 	return(SUBROUTINE);}
"END"		{printf("Found END keyword\n"); 	return(END);}
"COMMON"	{printf("Found COMMON keyword\n"); 	return(COMMON);}
"INTEGER"	{printf("Found INTEGER keyword\n"); 	return(INTEGER);}
"REAL"		{printf("Found REAL keyword\n"); 	return(REAL);}
"COMPLEX"	{printf("Found COMPLEX keyword\n"); 	return(COMPLEX);}
"LOGICAL"	{printf("Found LOGICAL keyword\n"); 	return(LOGICAL);}
"CHARACTER"	{printf("Found CHARACTER keyword\n"); 	return(CHARACTER);}
"STRING"	{printf("Found STRING keyword\n"); 	return(STRING);}
"LIST"		{printf("Found LIST keyword\n"); 	return(LIST);}
"DATA"		{printf("Found DATA keyword\n");	return(DATA);}	
"CONTINUE"	{printf("Found CONTINUE keyword\n");	return(CONTINUE);}
"GOTO"		{printf("Found GOTO keyword\n");	return(GOTO);}
"CALL"		{printf("Found CALL keyword\n");	return(CALL);}
"READ"		{printf("Found READ keyword\n");	return(READ);}
"WRITE"		{printf("Found WRITE keyword\n");	return(WRITE);}
"LENGTH"	{printf("Found LENGTH keyword\n");	return(LENGTH);}
"IF"		{printf("Found IF keyword\n");		return(IF);}
"THEN"		{printf("Found THEN keyword\n");	return(THEN);}
"ELSE"		{printf("Found ELSE keyword\n");	return(ELSE);}
"ENDIF"		{printf("Found ENDIF keyword\n");	return(ENDIF);}
"DO"		{printf("Found DO keyword\n");		return(DO);}
"ENDDO"		{printf("Found ENDDO keyword\n");	return(ENDDO);}
"STOP"		{printf("Found STOP keyword\n");	return(STOP);}
"RETURN"	{printf("Found RETURN keyword\n");	return(RETURN);}

{IDRULE2}|{IDRULE1}	{printf("Found ID\n"); 
			 yylval.id = (char *)malloc((yyleng + 1) * sizeof(char));
			 if (!yylval.id) {
			    printf("memory allocation error\n"); exit(0);
			 }
			 strcpy(yylval.id, yytext); 
			 
			 return(ID);
			}

\"			{i = 0; BEGIN(STRINGS);} 

. 			{yyerror("LEXICAL"); }
}


<STRINGS> 
{

\"			{ printf("\nEND OF STRING\n"); array[i] = '\0'; memcpy(yylval.sconst, array, 1000*sizeof(char)); BEGIN(INITIAL); return(SCONST);}

\\n			{string_function(yytext);}
\\b			{string_function(yytext);}
\\t			{string_function(yytext);}
\\r			{string_function(yytext);}
\\f			{string_function(yytext);}
\\v			{string_function(yytext);}
\\\			{string_function(yytext);}
.			{string_function(yytext);}
}

<<EOF>>			{printf("Found ENDOFFILE\n");return(0);}
%%
 void octtodec_function(char *s){
    int j;
    double new_num=0;
    int k;
    double a=1;
    double b=(0.125);
    for(j=2; j<yyleng; j++){
	if(s[j]=='.'){
	  k=j; 
	}}
    for(j=k-1; j>=2; j--){
	
	  if(s[j]=='1'||s[j]=='2'||s[j]=='3'||s[j]=='4'||s[j]=='5'||s[j]=='6'||s[j]=='7'){
	    new_num=new_num + a;
	  }
	  a=a*8;
    }
    for(j=k+1; j<yyleng; j++){
	  if(s[j]=='1'||s[j]=='2'||s[j]=='3'||s[j]=='4'||s[j]=='5'||s[j]=='6'||s[j]=='7'){
	    new_num=new_num + b; 
	  }
	  b=b/8;
    }  
    yylval.rconst=new_num;
} 
 void bintodec_function(char *s){
    int i;
    int new_num=0;
    int a=1;
    for(i=yyleng-1; i>=2; i--){
      if(s[i]=='1'){
	new_num=new_num + a;
      }
      a=a*2;
  }
  yylval.iconst=new_num;
}
 void bintodec_function2(char *s){
    int j;
    double new_num=0;
    int k;
    double a=1;
    double b=(0.5);
    for(j=2; j<yyleng; j++){
	if(s[j]=='.'){
	  k=j; 
	}}
    for(j=k-1; j>=2; j--){
	
	  if(s[j]=='1'){
	    new_num=new_num + a;
	  }
	  a=a*2;
    }
    for(j=k+1; j<yyleng; j++){
	  if(s[j]=='1'){
	    new_num=new_num + b; 
	  }
	  b=b/2;
    }  
    yylval.rconst=new_num;
}
 void char_function(char s){
  int j=1;
  switch(s){
    case 'n': {yylval.cconst='\n'; break;}
    case 't': {yylval.cconst='\t'; break;}
    case 'f': {yylval.cconst='\f'; break;}
    case 'v': {yylval.cconst='\v'; break;}
    case 'r': {yylval.cconst='\r'; break;}
    case 'b': {yylval.cconst='\b'; break;}
    default: break; 
  }
}
 void string_function(char* s){
  
    if(strcmp(s,"\\n")==0){
      array[i]='\n';
      i++;
    }
    else if(strcmp(s,"\\b")==0){
      array[i]='\b';
      i++;
    }
    else if(strcmp(s,"\\t")==0){
      array[i]='\t';
      i++;
    }
    else if(strcmp(s,"\\r")==0){
      array[i]='\r';
      i++;
    }
    else if(strcmp(s,"\\f")==0){
      array[i]='\f';
      i++;
    }
    else if(strcmp(s,"\\v")==0){
      array[i]='\v';
      i++;
    }
    else if(strcmp(s,"\\")==0){
      array[i]='\\';
      i++;
    }
    else{
      printf("%s",s);
      array[i]=s[0];
      i++;
    }

  
  }

 void yyerror(char *s){

  
  printf("\nERROR  %s\nline %d: %s\n", s, yylloc.first_line, line);
  error=error++;
  if(error>6){
    abort();
  }
}

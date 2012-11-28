%{
  #include "table.h"
  static int scope=0;
  static int type=0;
  void yyerror(char *s);
%}
%start program 
%token
 END 
 COMMON
 DATA
 INTEGER
 REAL
 COMPLEX
 LOGICAL
 CHARACTER
 STRING
 COMMA
 LPAREN
 RPAREN
 LIST
 ICONST
 OROP
 DIVOP
 ADDOP
 MULOP
 RCONST 
 LCONST 
 CCONST 
 SCONST
 COLON
 LISTFUNC
 LENGTH
 ANDOP
 NOTOP
 POWEROP
 RELOP
 LBRACK
 RBRACK
 GOTO
 CONTINUE 
 RETURN 
 STOP
 IF 
 THEN
 ELSE
 ENDIF
 READ
 WRITE
 ASSIGN
 SUBROUTINE
 FUNCTION
 DO
 ENDDO
 CALL
 ID
%type<id> ID
%right POWEROP
%left  MULOP DIVOP 
%left<addop_type>  ADDOP
%nonassoc RELOP 
%nonassoc NOTOP 
%left  ANDOP
%left  OROP
%locations
%union{
  char *id;
  int iconst, lconst;
  double rconst;
  char  sconst[1000];
  char cconst;
  int addop_type;
  int relop;
  char *listfunc;
  
}


%%
  program: {scope++;}body END {delsym(scope); scope--;} subprograms
	| error END		{yyerrok;  yyerror("SYNTAX");}
      ;
  body: declarations statements
      ;
  declarations: declarations type vars
      | declarations COMMON cblock_list
      | declarations DATA vals
      | 
      ;
  type: INTEGER 	{type=1;}
      | REAL 		{type=2;}
      | COMPLEX 	{type=3;}
      | LOGICAL 	{type=4;}
      | CHARACTER 	{type=5;}
      | STRING 		{type=6;}
      ;
  vars: vars COMMA undef_variable
      | undef_variable
      ;
  undef_variable: listspec ID LPAREN dims RPAREN
      | listspec ID 		{type=7; putsym($2,type,scope);}
      ;
  listspec: LIST 
      | 
      ;
  dims: dims COMMA dim 
      | error COMMA	{yyerrok; yyerror("SYNTAX");}
      | dim
      ;
  dim: ICONST 
      | ID
      ;
  cblock_list: cblock_list cblock 
      | cblock
      ;
  cblock: DIVOP ID DIVOP id_list
      ;
  id_list: id_list COMMA ID 
      | ID 			{putsym($1,type,scope); }
      ;
  vals: vals COMMA ID value_list
      | ID value_list
      ;
  value_list: DIVOP values DIVOP
      ;
  values: values COMMA value 
      | value
      | error COMMA  	{yyerrok; yyerror("SYNTAX");}
      ;
  value: repeat sign constant
      | ADDOP constant
      | constant
      ;
  repeat: ICONST MULOP
      | MULOP
      ;
  sign: ADDOP 
      | 
      ;
  constant: simple_constant
      | complex_constant
      ;
  simple_constant: ICONST 
      | RCONST 
      | LCONST 
      | CCONST 
      | SCONST
      ;
  complex_constant: LPAREN RCONST COLON sign RCONST RPAREN
      ;
  statements: statements labeled_statement 
      | labeled_statement
      ;
  labeled_statement: label statement 
      | statement
      ;
  label: ID
      ;
  statement: simple_statement 
      | compound_statement
      ;
  simple_statement: assignment
      | goto_statement
      | if_statement
      | subroutine_call
      | io_statement
      | CONTINUE
      | RETURN
      | STOP
      ;
  assignment: variable ASSIGN expression
      ;
  variable: ID LPAREN expressions RPAREN
      | LISTFUNC LPAREN expression RPAREN
      | ID
      ;
  expressions: expressions COMMA expression
      | error COMMA {yyerrok; yyerror("SYNTAX");}
      | expression
      ;
  expression: expression OROP expression
      | expression ANDOP expression
      | expression RELOP expression
      | expression ADDOP expression
      | expression MULOP expression
      | expression DIVOP expression
      | expression POWEROP expression
      | NOTOP expression
      | ADDOP expression
      | variable
      | simple_constant
      | LENGTH LPAREN expression RPAREN
      | LPAREN expression RPAREN
      | LPAREN expression COLON expression RPAREN
      | listexpression
      ;
  listexpression: LBRACK expressions RBRACK
      | LBRACK RBRACK 
      ;
  goto_statement: GOTO label
      | GOTO ID COMMA LPAREN labels RPAREN 
      ;
  labels: labels COMMA label 
      | label 
      ;
  if_statement: IF LPAREN expression RPAREN label COMMA label COMMA label
      | IF LPAREN expression RPAREN simple_statement 
      ;
  subroutine_call: CALL variable
      ;
  io_statement: READ read_list 
      | WRITE write_list 
      ;
  read_list: read_list COMMA read_item 
      | read_item 
      ;
  read_item: variable 
      | LPAREN read_list COMMA ID ASSIGN iter_space RPAREN 
      ;
  iter_space: expression COMMA expression step 
      ;
  step: COMMA expression 
      |  
      ;
  write_list: write_list COMMA write_item 
      | write_item 
      ;
  write_item: expression 
      | LPAREN write_list COMMA ID ASSIGN iter_space RPAREN 
      ;
  compound_statement: branch_statement 
      | loop_statement 
      ;
  branch_statement: IF LPAREN expression RPAREN THEN body tail 
      ;
  tail: ELSE body ENDIF 
      |ENDIF
      ;
  loop_statement: DO ID ASSIGN iter_space body ENDDO 
		|  DO ID ASSIGN error ENDDO	{yyerrok; yyerror("SYNTAX");}
		;
  subprograms: subprograms subprogram 
      |  
      ;
  subprogram: {scope++;}header body END{delsym(scope); scope--; printtable();} 
      ;
  header: type listspec FUNCTION ID LPAREN formal_parameters RPAREN 		{type=8; putsym($4,type,scope); }
      | error RPAREN	    							{yyerrok; yyerror("SYNTAX");}
      | SUBROUTINE ID LPAREN formal_parameters RPAREN 				{type=9;putsym($2,type,scope); }
      | SUBROUTINE ID 								{type=9;putsym($2,type,scope); }
      ;
  formal_parameters: type vars COMMA formal_parameters
      | type vars 
      ;
%%

int main(int argc, char *argv[]) {

  int retVal;

  retVal = yyparse();

  if (retVal == 0) {

    printf("Successful parsing\n");
    

  }
  else {

    printf("Error during parsing\n");
  }
 // fflush(stdout);

  return(0);

}
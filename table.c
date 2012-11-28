#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "syntax.tab.h"



struct symrec{
  char *name;
  int type;
  int scope;
 // int visibility;

  struct symrec *next;
};

typedef struct symrec symrec;

extern symrec *sym_table;

symrec *putsym(const char *s, int type , int scope);
symrec *getsym(const char *s);
symrec *delsym(int scope);
symrec *printtable();
symrec *printscope();

symrec *sym_table=(symrec *) 0;

symrec *putsym(const char *sym_name, int sym_type, int sym_scope){
  symrec *ptr;
  ptr =(symrec *)malloc(sizeof (symrec));
  ptr->name=(char *)malloc(strlen (sym_name)+1);
  strcpy(ptr->name, sym_name);
  ptr->type=sym_type;
  ptr->scope=sym_scope;
  ptr->next=(struct symrec *)sym_table;
  sym_table=ptr;
 
  return ptr;
}

symrec *getsym (const char *sym_name)
{
  symrec *ptr;
  ptr=sym_table;
  do
  {
    if(strcmp(ptr->name,sym_name)==0)
    {
      printf("name: %s,type: %d,scope: %d\n",ptr->name,ptr->type,ptr->scope);
      return ptr;  
    }   
    ptr=(symrec *)ptr->next;
    
  }while( ptr !=(symrec *)0);
  
  return 0;
}


symrec *delsym (int sym_scope)
{
  symrec *ptr;
  symrec *temp;
  ptr=sym_table;
  temp=NULL;
  while(ptr !=(symrec *)0 )
  {
    if(sym_scope==ptr->scope){ 
      if(temp==NULL){
	sym_table=ptr->next;
	free(ptr);
	ptr=sym_table;
      }
      else{
	temp->next=ptr->next;
	free(ptr);
	ptr=temp->next;
      }
    }
    else{
      temp=ptr;
      ptr=(symrec *)ptr->next;      
    }
  }

  return 0;
}


symrec *printtable(){
  symrec *ptr = sym_table;
 do
  {
    {printf("%s\n",ptr->name);}
  
    ptr = ptr->next;
  }while( ptr!=(symrec *)0);
}

symrec *printscope(){
    symrec *ptr = sym_table;
 do
  {
    {printf("scope is: %d\n",ptr->scope);}
  
    ptr = ptr->next;
  }while( ptr!=(symrec *)0);
}

































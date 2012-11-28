struct symrec{
  char *name;
  int type;
  int scope;
 // int visibility;

  struct symrec *next;
};
struct symrec *putsym(const char *s, int type , int scope);
struct symrec *getsym(const char *s);
struct symrec *delsym(int scope);
struct symrec *printtable();
struct symrec *printscope();
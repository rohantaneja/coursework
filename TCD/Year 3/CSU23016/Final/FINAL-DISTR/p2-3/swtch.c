#include "types.h"
#include "defs.h"
#include "param.h"
#include "proc.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

uint swtchLimit = 1000 ; // default value

enum actiontype { EXIT // -
                , CPU  // -
                , READ // fileno
                , WRT  // fileno
                , WAIT //
                , WAKE // procno
                , KILL // procno
                } ;

void printacttype(enum actiontype atype){
  switch(atype) {
    case EXIT : printf("EXIT"); break;
    case CPU  : printf("CPU"); break;
    case READ : printf("READ"); break;
    case WRT  : printf("WRT"); break;
    case WAIT : printf("WAIT"); break;
    case WAKE : printf("WAKE"); break;
    case KILL : printf("KILL"); break;
    default   : printf("????");
  }
}

struct action {
  enum actiontype atype;
  int apar;              // parameter for READ, WRT, WAKE, and KILL
};

void printaction(struct action *a){
  printacttype(a->atype);
  if(a->apar>=0) {printf("(%d)",a->apar);}
}

#define MAXACT 50

struct acts {
  struct action *next;
  struct action actions[MAXACT];
};

struct acts pactions[NPROC];

int initaction(struct action *a){
  a->atype = 999;
  a->apar = -1;
  return 0;
}

int initact(struct acts *as){

  struct action *a;
  int i;

  a = as->actions;
  for(i=0;i<MAXACT;i++){
    initaction(&a[i]);
  }
  as->next = NULL;
  return 0;
}


int initpactions() {
  struct acts *a;

  for(a = pactions; a < &pactions[NPROC]; a++) {
    initact(a);
  }
  return 1;
}

// if action is EXIT, return 0, otherwise one.
int readaction(char *tokp, struct acts *as, int l_a){
  // char l_types[10];
  enum actiontype l_atype;
  int l_apar; // target parameter
  int rc;
  int arc;

  l_atype=999; l_apar=999;
  as->next = &as->actions[l_a];

  // CPU | READ 1 | WRT 2 | WAIT | SLP 200 | WAKE 2 | FORK 4 | KILL 0 | EXIT
  tokp = strtok( NULL, WSEP);
  // rc = sscanf(line,"%s",tokp);
  //printf("RA:tok3..=%s\n",tokp);
  arc=1;
  if (strcmp(tokp,"CPU")==0) {
    l_atype = CPU; l_apar = -1;

  } else if (strcmp(tokp,"READ")==0) {
    l_atype = READ;
    tokp = strtok( NULL, WSEP);
    rc = sscanf(tokp, "%d",&l_apar);

  } else if (strcmp(tokp,"WRT")==0) {
    l_atype = WRT; l_apar = -1;
    tokp = strtok( NULL, WSEP);
    rc = sscanf(tokp, "%d",&l_apar);

  } else if (strcmp(tokp,"WAIT")==0) {
    l_atype = WAIT; l_apar = -1;

  } else if (strcmp(tokp,"WAKE")==0) {
    l_atype = WAKE;
    tokp = strtok( NULL, WSEP);
    rc = sscanf(tokp, "%d",&l_apar);

  } else if (strcmp(tokp,"KILL")==0) {
    l_atype = KILL;
    tokp = strtok( NULL, WSEP);
    rc = sscanf(tokp, "%d",&l_apar);

  } else if (strcmp(tokp,"EXIT")==0) {
    l_atype = EXIT; l_apar = -1; arc=0;

  } else {
    printf("Unknown token %s\n", tokp);
  }
  as->next->atype = l_atype;
  as->next->apar = l_apar;
  printf(" ");
  printaction(as->next);
  printf("\n");

  return arc;
}

int readactions(FILE *fp){

  char line[256];
  char *tokp;
  int l_p; // pactions index
  char stuff[6];

  int rc;
  struct acts *as;
  int l_a; // actions index
  struct action *a;

  l_p=999;

  // ACT 3
  fgets( line, 255, fp);
  //printf("RAS:LINE IS %s\n", line);
  tokp = strtok( line, WSEP);  // should be "ACT"
  //printf("RAS:tok1 IS %s\n", tokp);

  tokp = strtok( NULL, WSEP);
  //printf("RAS:tok2 IS %s\n", tokp);
  rc = sscanf(tokp, "%d", &l_p);
  //printf("rc=%d, p=%d\n",rc,l_p);
  as = &pactions[l_p];
  l_a=0;
  while(readaction(tokp,as,l_a)){
    // printf("Action %d read!\n",l_a);
    l_a++;
  }
  // p->next = p->actions;
  // printf("Actions:\n");
  // for(a = p->actions; a < &p->actions[MAXACT]; a++) {
  //   printacttype(a->atype);
  //   if(a->apar >= 0) {printf("(%d)",a->apar);}
  //   printf("\n");
  // }
  as->next = as->actions;
  return rc;
}


struct action *getnextaction(struct proc *p){
  int l_pid;
  struct acts *as;
  struct action *a;

  l_pid = p->pid;
  as = &pactions[l_pid];
  a = (as->next)++;
  return a;
}


void swtch(struct proc *p){
   struct action *a;
   int runtime;

   printf("RUNNING: %s prio:%u @%6dms doing ",p->name,p->dynprio,clock);
   a = getnextaction(p);
   printaction(a); printf("\n");

   runtime = 0;
   switch(a->atype) {

     case EXIT :
       p->state = ZOMBIE;
       runtime = 5;
       break;

     case CPU  :
       p->state = RUNNABLE;
       runtime = p->quantum;
       break;

     case READ :
       doRead(a->apar);
       p->state = RUNNABLE;
       runtime = 100;
       break;

     case WRT  :
       doWrite(a->apar);
       p->state = RUNNABLE;
       runtime = 200;
       break;

     case WAIT :
       p->state = SLEEPING;
       runtime = 10;
       break;

     case WAKE : // only wake sleepers !
       if(ptable.proc[a->apar].state == SLEEPING) {
         ptable.proc[a->apar].state = RUNNABLE;
       }
       p->state = RUNNABLE;
       runtime = 5;
       break;

     case KILL :
       ptable.proc[a->apar].state = ZOMBIE;
       p->state = RUNNABLE;
       runtime = 5;
       break;

     default   :
       p->state = ZOMBIE;
   }

   clock += runtime ;
   p->lastrun = clock;

   if(!swtchLimit--) {
     printf("switch-limit reached!\n" );
     exit(0);
   }
}

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "types.h"
#include "defs.h"
#include "param.h"
#include "proc.h"
#include "fs.h"
#include "buf.h"
#include "file.h"

int readfilestat(FILE *fp) {
  char line[80];
  char stuff[80];
  uint l_f; // ftable/inode index
  char l_name[FNLEN] ; // Filename (debugging)
  char l_rw;

  int rc;
  struct file *f;
  int frc;
  struct inode *i ;


  fgets ( line, 79, fp );

#define FILEHDR 4 // FILE f name r/w

  rc = sscanf(line, "%s %u %s %c", stuff, &l_f, l_name, &l_rw );
  if (rc==FILEHDR && strcmp(stuff,"FILE")==0) {
    printf( "FILE %d '%s' r/w: %c\n", l_f, l_name, l_rw );
    f = &ftable.file[l_f];
    i = &inodes[l_f] ; // inode has same array index as file
    strcpy(f->fname,l_name);
    f->type  = FD_INODE;
    f->ref = 1 ;
    f->readable = (l_rw == 'r') ;
    f->writable = (l_rw == 'w') ;
    f->off = 0;
    f->ip = i;

    i->ref = 1 ;
    i->valid = 1 ;
    i->nlink = 1 ;
    i->size = 0 ;

    return 1 ;
  }

#define BLKHDR 2  // BLK f

  rc = sscanf(line, "%s %u", stuff, &l_f );
  if (rc==BLKHDR && strcmp(stuff,"BLK")==0) {

    uint oldsize;
    uint newsize;
    uint bno;
    uint addr;

    frc=1;
    f = &ftable.file[l_f];
    i = &inodes[l_f] ; // inode has same array index as file
    oldsize = i->size;
    bno = oldsize/BSIZE;
    addr = bmap(i,bno);
    newsize = oldsize+BSIZE;
    i->size = newsize;
    disk1[addr].blockno = bno;
    printf( "BLK %u %u +-> %u @ %u\n", l_f, oldsize, newsize, addr);
    sprintf(disk1[addr].data,"F%u B%u @%u",l_f,bno,addr);

    return 1;
  }

#define ENDF 1  // ENDFILES

  rc = sscanf(line, "%s", stuff );
  if (rc!=ENDF || strcmp(stuff,"ENDFILES")!=0) {
    printf("Expected %d items, found %d\n", FILEHDR, rc );
  }
  return 0;

}

void showfiles() {
  uint i;
  struct file *fp;
  struct inode *ip;
  uint bcount;
  uint b;
  uint a;

  for( i=0; i<NINODE; i++) {
    fp = &ftable.file[i];
    ip = &inodes[i];
    if (ip->ref) {
      printf("FILE CONTENTS for '%s'\n", fp->fname);
      bcount = (ip->size)/BSIZE;
      for( b=0; b < bcount; b++) {
        a = bmap(ip, b);
        printf(" @%u->%u : %s\n",b,a,disk1[a].data);
      }
    }
  }
}

void diskdump() {
   uint a;

   printf("DISK DUMP\n");
   for( a=0; a < 40; a++) {
     printf("[%2u] : %s\n", a, disk1[a].data);
   }
}


void initptable () {
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    p->state = UNUSED;
    p->pid  = 0;
    p->name[0] = 0;
    p->staticprio = 9999;
    p->lastrun = 0;
    initproc(p);
  }
}

int readproc(FILE *fp) { // returns 0 if not a proc, 1 otherwise
  char line[256];
  int l_p; // ptable index
  int l_state;        // Process state
  char l_name[17];               // Process name (debugging)
  uint l_prio;                     // Process priority
  char stuff[6];

  int rc;
  struct proc *p;
  int prc;

  l_p=999; l_state=999; l_prio=999;

// PROC p state name prio
#define PROCHDR 5

  fgets ( line, 255, fp );
  //printf("RP:LINE IS %s\n",line);
  rc = sscanf(line,  "%s %u %u %s %u"
    , stuff, &l_p, &l_state, l_name, &l_prio );
  // printf("rc=%d, stuff=%s\n",rc,stuff);
  if(rc==PROCHDR && strcmp(stuff,"PROC")==0){
    prc=1;
    printf( "PROCESS %d ", l_p );
    printstate(l_state);
    printf( " '%s' prio: %u\n", l_name, l_prio);
    p = &ptable.proc[l_p]; p->pid  = l_p; // VERY IMPORTANT!!
    p->state = l_state;
    strcpy(p->name,l_name);
    p->staticprio = l_prio;
    p->lastrun = 0;
    p->avgsleep = 0;
    p->quantum = 100;
    p->dynprio  = l_prio;
  } else {
    if(rc>=0) {printf("Expected %d items, found %d\n", PROCHDR, rc );}
    prc=0;
  }
  return prc;
}


void loadtables() {
  FILE *fp;
  char line[80];

  // fp = fopen( "setup.txt", "r");
  fp = stdin;

  while(readfilestat(fp));

  showfiles();
  diskdump();

  fgets( line, 79, fp );
  sscanf(line,"%u",&swtchLimit);
  while(readproc(fp)){
    readactions(fp);
  }
}

int main (int argc, const char * argv[]) {

  printf("\n\tWelcome to the xv6 Filesystem Simulator!\n\n");
  printf("\nNDIRECT=%d, NINDIRECT=%lu\n",NDIRECT,NINDIRECT);
  initptable();
  initpactions();
  ideinit();
  initfiletables();
  loadtables();
  printf("STARTING SCHEDULER\n");
  clock=0;
  scheduler();

  showfiles();
  diskdump();

  return EXIT_SUCCESS;

}

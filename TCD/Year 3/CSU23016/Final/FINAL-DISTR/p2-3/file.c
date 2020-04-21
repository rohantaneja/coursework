//
// File descriptors
//

#include <stdlib.h>
#include <stdio.h>
#include "types.h"
#include "defs.h"
#include "param.h"
#include "fs.h"
// #include "spinlock.h"
// #include "sleeplock.h"
#include "file.h"


void initfiletables() {
  int i;

  for(i=0; i < NFILE; i++) {
    ftable.file[i].type = FD_NONE ;
    ftable.file[i].ref = 0 ; // reference count
    ftable.file[i].readable = 0 ;
    ftable.file[i].writable = 0 ;
    ftable.file[i].ip = NULL ;
    ftable.file[i].off = 0 ;
  }

  for(i=0; i < NINODE; i++) {
    inodes[i].dev = ROOTDEV ;           // Device number
    inodes[i].inum = i ;          // Inode number
    inodes[i].ref = 0 ;            // Reference count
    inodes[i].valid = 0 ;          // inode has been read from disk?
    inodes[i].nlink = 0 ;
    inodes[i].size = 0;
    int a;
    for(a=0; a < NDIRECT+1+1+1; a++) {
    inodes[i].addrs[a] = 0 ;
    }
  }
}

void
doRead(uint fno) {
  struct file *f;
  char reading[BSIZE];
  int rc;

  f = &ftable.file[fno];
  rc=fileread(f,reading,BSIZE);

  printf("FILE-READ %u YIELDS '%s'\n",fno,reading);
}

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
  int r;

  if(f->readable == 0)
    return -1;
  // if(f->type == FD_PIPE)
  //   return piperead(f->pipe, addr, n);
  printf("\tREADABLE\n");
  if(f->type == FD_INODE){
    // ilock(f->ip);
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    // iunlock(f->ip);
    return r;
  }
  panic("fileread");
  return -1;
}

//PAGEBREAK!
void
doWrite(uint fno) {
  struct file *f;
  struct inode *i;
  char writing[BSIZE];
  int rc;

  f = &ftable.file[fno];
  i = &inodes[fno];
  sprintf(writing,"WRT F%u @ %u",fno,i->size);
  rc=filewrite(f,writing,BSIZE);

  printf("FILE-WRITE %u PRODUCES '%s'\n",fno,writing);
}


// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
  int r;

  if(f->writable == 0)
    return -1;
  // if(f->type == FD_PIPE)
  //   return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
      if ((r = writei(f->ip, addr, f->off, n)) > 0)
        f->off += r;
      //printf("SHORT: r=%d n=%d\n",r,n);
      if(r != n)
        panic("short filewrite");

    //   i += r;
    // }
    return r == n ? n : -1;
  }
  panic("filewrite");
  return -1;
}

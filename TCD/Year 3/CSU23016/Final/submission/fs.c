// File system implementation.  Five layers:
//   + Blocks: allocator for raw disk blocks.
//   + Log: crash recovery for multi-step updates.
//   + Files: inode allocator, reading, writing, metadata.
//   + Directories: inode with special contents (list of other inodes!)
//   + Names: paths like /usr/rtm/xv6/fs.c for convenient naming.
//
// This file contains the low-level file system manipulation
// routines.  The (higher-level) system call implementations
// are in sysfile.c.

#include <string.h>
#include <stdio.h>
#include "types.h"
#include "defs.h"
#include "param.h"
//#include "stat.h"
// #include "mmu.h"
#include "proc.h"
// #include "spinlock.h"
// #include "sleeplock.h"
#include "fs.h"
#include "buf.h"
#include "file.h"

#define min(a, b) ((a) < (b) ? (a) : (b))
static void itrunc(struct inode*);
// there should be one superblock per disk device, but we run with
// only one device
struct superblock sb;

// Read the super block.
// void
// readsb(int dev, struct superblock *sb)
// {
//   struct buf *bp;
//
//   bp = bread(dev, 1);
//   memmove(sb, bp->data, sizeof(*sb));
//   brelse(bp);
// }

// Zero a block.
// static void
// bzero(int dev, int bno)
// {
//   struct buf *bp;
//
//   bp = bread(dev, bno);
//   memset(bp->data, 0, BSIZE);
//   log_write(bp);
//   brelse(bp);
// }

// Blocks.

// Allocate a zeroed disk block.
uint
balloc(uint dev)
{
  int b;
  for( b=1; b < DISKSIZE; b++) {
    //printf("Checking %u\n", b);
    if (!used[b]) {
       used[b] = 1;
       return b;
    }
    //printf( "Block %u is used\n", b);
  }
  panic("balloc: out of blocks");
  return 0;
}


// Free a disk block.
static void
bfree(int dev, uint b)
{
  struct buf *bp;
  int bi, m;

  // readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb));
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
  // log_write(bp);
  // brelse(bp);
}

void
initindirect() {
  int i,j ;
  for( i=0; i<MAXINDIRECT; i++) {
    iused[i]=0;
    for( j=0; j<NINDIRECT; j++) indirect[i][j] = 0;
  }
}

uint
indalloc()
{
  int b;
  for( b=1; b < MAXINDIRECT; b++) {
    //printf("Checking %u\n", b);
    if (!iused[b]) {
       iused[b] = 1;
       return b;
    }
    //printf( "Indirect Block %u is used\n", b);
  }
  panic("indalloc: out of blocks");
  return 0;
}


//PAGEBREAK!
// Inode content
//
// The content (data) associated with each inode is stored
// in blocks on the disk. The first NDIRECT block numbers
// are listed in ip->addrs[].  The next NINDIRECT blocks are
// listed in block ip->addrs[NDIRECT].

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
uint
bmap(struct inode *ip, uint bn)
{
  uint addr, *a;
  struct buf *bp;

  //printf("bmap bn=%u\n",bn);
  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    //printf("bmap returns %u\n",addr);
    return addr;
  }
  bn -= NDIRECT;
  //printf("going indirect!, bn now %u\n",bn);

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = indalloc(); // need to allocate indirect
                                              // page from "RAM"
    // bp = bread(ip->dev, addr);
    a = indirect[addr];
    if((addr = a[bn]) == 0){
      a[bn] = addr = balloc(ip->dev);
      // log_write(bp);
    }
    // brelse(bp);
    //printf("bmap returns %u\n",addr);
    return addr;
  }
  // tanejar's addition
  bn -= NINDIRECT;
  //printf("going indirect level 2!, bn now %u\n",bn);

  if(bn < NIND2){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT+1]) == 0)
      ip->addrs[NDIRECT+1] = addr = indalloc(); // need to allocate indirect
                                              // page from "RAM"
    // bp = bread(ip->dev, addr);
    a = indirect[addr]; //1st layer
    if((addr = a[bn/(NINDIRECT)]) == 0){
      a[bn/(NINDIRECT)] = addr = balloc(ip->dev);
      // log_write(bp);
    }
    
    a = indirect[addr]; //2nd layer
    if((addr = a[bn%(NINDIRECT)]) == 0){
      a[bn%(NINDIRECT)] = addr = balloc(ip->dev);
      // log_write(bp);
    }
    // brelse(bp);
    //printf("bmap returns %u\n",addr);
    return addr;
  }
  
  bn -= NIND2;
  //printf("going indirect level 3!, bn now %u\n",bn);

  if(bn < NIND3){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT+2]) == 0)
      ip->addrs[NDIRECT+2] = addr = indalloc(); // need to allocate indirect
                                              // page from "RAM"
    // bp = bread(ip->dev, addr);
    a = indirect[addr]; //1st layer
    if((addr = a[bn/NIND2]) == 0){
      a[bn/NIND2] = addr = balloc(ip->dev);
      // log_write(bp);
    }
    
    a = indirect[addr]; //2nd layer
    if((addr = a[bn/NINDIRECT]) == 0){
      a[bn/NINDIRECT] = addr = balloc(ip->dev);
      // log_write(bp);
    }

    a = indirect[addr]; //3rd layer
    if((addr = a[bn%(NINDIRECT)]) == 0){
      a[bn%(NINDIRECT)] = addr = balloc(ip->dev);
      // log_write(bp);
    }
    // brelse(bp);
    //printf("bmap returns %u\n",addr);
    return addr;
  }
  
  //bn -= NIND3; //maybe needed?
  
  panic("bmap: out of range");
  return 0;
}



//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;
  uint addr;

  // if(ip->type == T_DEV){
  //   if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
  //     return -1;
  //   return devsw[ip->major].read(ip, dst, n);
  // }

  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  //printf("\tREADI n=%u\n",n);
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    addr = bmap(ip, off/BSIZE);
    //printf("\tREADI off=%u, addr=%u\n",off,addr);
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    // brelse(bp);
  }
  return n;
}

// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;
  uint addr;

  // if(ip->type == T_DEV){
  //   if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
  //     return -1;
  //   return devsw[ip->major].write(ip, src, n);
  // }

  //printf("WRI(size=%u, off=%u, n=%u)\n",ip->size,off,n);
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  //printf("\tWRITEI n=%u\n",n);
  //for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    tot=0;
    addr = bmap(ip, off/BSIZE);
    //printf("\tWRITEI off=%u, addr=%u\n",off,addr);
    //printf("Before: %s\n",disk1[addr].data);
    bp = bread(ip->dev, addr);
    //printf("After: %s\n",disk1[addr].data);

    m = min(n - tot, BSIZE - off%BSIZE);
    //printf("Src = %s, m= %u\n",src,m);
    memmove(bp->data + off%BSIZE, src, m);
    off += m;
    // log_write(bp);
    // brelse(bp);
  //}

  if(n > 0 && off > ip->size){
    ip->size = off;
    // iupdate(ip);
  }
  //printf("Done: n=%u, size=%u\n",n,ip->size);
  return n;
}
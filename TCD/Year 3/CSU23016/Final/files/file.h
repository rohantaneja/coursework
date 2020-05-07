
#define FNLEN 40

struct file {
  char fname[FNLEN] ;
  enum { FD_NONE, FD_PIPE, FD_INODE } type;
  int ref; // reference count
  char readable;
  char writable;
  // struct pipe *pipe;
  struct inode *ip;
  uint off;
};

struct {
  // struct spinlock lock;
  struct file file[NFILE];
} ftable;

// in-memory copy of an inode
struct inode {
  uint dev;           // Device number
  uint inum;          // Inode number
  int ref;            // Reference count
  // struct sleeplock lock; // protects everything below here
  int valid;          // inode has been read from disk?

  // short type;         // copy of disk inode
  // short major;
  // short minor;
  short nlink;
  uint size;
  uint addrs[NDIRECT+1+1+1];
};

struct inode inodes[NINODE];

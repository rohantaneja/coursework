// GLOBAL CLOCK USED BY SIMULATOR
int clock;


struct buf;
struct file;
struct inode;
struct proc;
struct superblock;


// proc.c
enum procstate;
void printstate(enum procstate pstate);
void initproc(struct proc *);
struct proc *p;
struct cpu *c;
void scheduler(void);

// swtch.S
void swtch(struct proc *p);
uint swtchLimit ;

int initpactions();
int readactions();

// file.c
void initfiletables();
void doRead(uint);
int fileread(struct file *, char *, int);
void doWrite(uint);
int filewrite(struct file *, char *, int);

// fs.c
int readi(struct inode*, char*, uint, uint);
int writei(struct inode*, char*, uint, uint);
void initindirect();
uint indalloc();
uint balloc(uint);
uint bmap(struct inode *, uint);

// console.c
void panic(char *s);

// bio.c
struct buf* bread(uint, uint);

// ide.c
void ideinit(void);
void iderw(struct buf*);

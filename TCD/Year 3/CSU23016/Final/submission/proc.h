#define NPROC 10

enum procstate { UNUSED, EMBRYO, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };

// Per-process state
struct proc {
  // uint sz;                     // Size of process memory (bytes)
  // pde_t* pgdir;                // Page table
  // char *kstack;                // Bottom of kernel stack for this process
  enum procstate state;        // Process state
  int pid;                     // Process ID - should equal ptable index
  // struct proc *parent;         // Parent process
  // struct trapframe *tf;        // Trap frame for current syscall
  // struct context *context;     // swtch() here to run process
  // void *chan;                  // If non-zero, sleeping on chan
  // int killed;                  // If non-zero, have been killed
  // struct file *ofile[NOFILE];  // Open files
  // struct inode *cwd;           // Current directory
  char name[16];               // Process name (debugging)
  int staticprio;  // Static Priority
  int lastrun;     // time when last finished executing
  // YOU NEED TO CALCULATE THE FOLLOWING PROPERLY:
  int avgsleep;    // Average sleep time
  int quantum;     // Base Time Quantum
  int dynprio;     // Dynamic Priority - used by scheduler
  // ADD EXTRA FIELDS BELOW AS REQUIRED
  int step;     // keep track of nos proc occurred
};

struct {
  // struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

// Per-CPU state
struct cpu {
  // uchar apicid;                // Local APIC ID
  struct context *scheduler;   // swtch() here to enter scheduler
  // struct taskstate ts;         // Used by x86 to find stack for interrupt
  // struct segdesc gdt[NSEGS];   // x86 global descriptor table
  // volatile uint started;       // Has the CPU started?
  // int ncli;                    // Depth of pushcli nesting.
  // int intena;                  // Were interrupts enabled before pushcli?
  struct proc *proc;           // The process running on this cpu or null
};

#define NCPU 1
#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

extern struct cpu cpus[NCPU];
extern int ncpu;
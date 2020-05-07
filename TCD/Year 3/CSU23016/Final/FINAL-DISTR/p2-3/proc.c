
#include "types.h"
#include "defs.h"
#include <stdio.h>
#include "proc.h"

#define NCPU 1

struct cpu cpus[NCPU];
int ncpu;

void printstate(enum procstate pstate){ // DO NOT MODIFY
  switch(pstate) {
    case UNUSED   : printf("UNUSED");   break;
    case EMBRYO   : printf("EMBRYO");   break;
    case SLEEPING : printf("SLEEPING"); break;
    case RUNNABLE : printf("RUNNABLE"); break;
    case RUNNING  : printf("RUNNING");  break;
    case ZOMBIE   : printf("ZOMBIE");   break;
    default       : printf("????????");
  }
}

// ONLY MODIFY THESE TWO NEXT FUNCTIONS

void initproc(struct proc *p) {
    p->avgsleep = 0;
    p->quantum = 0;
    p->dynprio = 0;
    // ADD EXTRA FIELD INITIALISATIONS BELOW AS REQUIRED
    p->counter = 0;
    p->avgsleep_log = 0;
}

void adjustpriority(struct proc *p) {
	
	/*
	adjustriority() divided into four sections of calc
	(1) - avgsleep time
	(2) - base time quantum
	(3) - bonus
	(4) - returning adjusted priority for process
	
	*/
	
	// section 1: avg sleep time calc
	p->avgsleep_log *= p->counter;
	p->avgsleep_log += clock - p->lastrun;
	
	p->counter++; // update proc counter - used to keep track
	p->avgsleep = (p->avgsleep_log)/(p->counter);
	
	// section 2: quantum calc
	if (p->staticprio < 120) {
		p->quantum = (140 - p->staticprio) * 20;
	}
	else {
		p->quantum = (140 - p->staticprio) * 5;
	}

	// section 3: bonus calculation
	int bonus;
	
	if(p->avgsleep < 100 && p->avgsleep >= 0) {
		bonus = 0;
	}	
	else if(p->avgsleep < 200 && p->avgsleep >= 100) {
		bonus = 1;
	}	
	else if(p->avgsleep < 300 && p->avgsleep >= 200) {
		bonus = 2;
	}	
	else if(p->avgsleep < 400 && p->avgsleep >= 300) {
		bonus = 3;
	}	
	else if(p->avgsleep < 500 && p->avgsleep >= 400) {
		bonus = 4;
	}	
	else if(p->avgsleep < 600 && p->avgsleep >= 500) {
		bonus = 5;
	}	
	else if(p->avgsleep < 700 && p->avgsleep >= 600) {
		bonus = 6;
	}	
	else if(p->avgsleep < 800 && p->avgsleep >= 700) {
		bonus = 7;
	}	
	else if(p->avgsleep < 900 && p->avgsleep >= 800) {
		bonus = 8;
	}	
	else if(p->avgsleep < 1000 && p->avgsleep >= 900) {
		bonus = 9;
	}	
	else if(p->avgsleep >= 1000) {
		bonus = 10;
	}
	
    // section 4: return adjusted priority from calc
    p->dynprio = max(100,min(p->staticprio-bonus+5,139));
}


// DO NOT MODIFY THIS
void adjustpriorities() {
  int i;
  struct proc *p;

    for (i=0; i < NPROC; i++) {
     p = &ptable.proc[i];
     if (p->state != UNUSED ) {
       adjustpriority(p);
     }
    }
}


// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.

// local to scheduler in xv6, but here we need them to persist outside,
// because while xv6 runs scheduler as a "coroutine" via swtch,
// here swtch is just a regular procedure call.


int pix;
struct proc *p;
struct cpu *c = cpus;


void
scheduler(void)
{ int runnableFound; // DO NOT MODIFY/DELETE
  int pix_lowest;
  int prio_lowest;
  int i;
  int srchix;

  c->proc = 0;

  runnableFound = 1 ; // force one pass over ptable

  while(runnableFound){ // DO NOT MODIFY
    // Enable interrupts on this processor.
    // sti();
    runnableFound = 0; // DO NOT MODIFY
    adjustpriorities(); // DO NOT MODIFY
    // Loop over process table looking for process to run.
    // acquire(&ptable.lock);
    for(pix = 0; pix < NPROC; pix++){
      p = &ptable.proc[pix];

      if(p->state != RUNNABLE)
        continue;

      runnableFound = 1; // DO NOT MODIFY/DELETE/BYPASS


      // We need to search whole ptable from here (pix) to find
      // the next process in round-robin order that has least priority number
      pix_lowest = pix;
      prio_lowest = p->dynprio;
      for (i=1; i < NPROC; i++){
        srchix = (pix+i)%NPROC;
        if(ptable.proc[srchix].state == RUNNABLE) {
          if(ptable.proc[srchix].dynprio < prio_lowest) {
            prio_lowest = ptable.proc[srchix].dynprio;
            pix_lowest = srchix;
          }
        }
      }
      p = &ptable.proc[pix_lowest];
      if( pix_lowest <= pix) adjustpriorities(); // we went around
      pix = pix_lowest;


      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      //switchuvm(p);
      p->state = RUNNING;


      swtch(p);
      // p->state should not be running on return here.
      //switchkvm();
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    // release(&ptable.lock);

  }
  printf("No RUNNABLE process at time %u\n",clock);
}

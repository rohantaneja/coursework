// Console input and output.
// Input is from the keyboard or serial port.
// Output is written to the screen and serial port.

#include "types.h"
#include "defs.h"
#include "param.h"
#include <stdio.h>
#include <stdlib.h>

void
panic(char *s)
{
  // int i;
  // uint pcs[10];

  // cli();
  // cons.locking = 0;
  // use lapiccpunum so that we can call panic from mycpu()
  //cprintf("lapicid %d: panic: ", lapicid());
  printf("PANIC @%dms ",clock);
  printf("%s",s);
  printf("\n");
  // getcallerpcs(&s, pcs);
  // for(i=0; i<10; i++)
  //   cprintf(" %p", pcs[i]);
  // panicked = 1; // freeze other CPU
  // for(;;)
  //   ;
  exit(EXIT_FAILURE);
}

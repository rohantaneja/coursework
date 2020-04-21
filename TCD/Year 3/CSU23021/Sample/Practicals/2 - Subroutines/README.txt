The Startup.s File

The file Startup.s is supplied by the Keil Development System itself to initialise the LPC2138 correctly.
In general, you don't need to do anything with it. Once it has initialised the LPC2138, it transfers
program execution to a label called "main" or "__main". This can be an assembly language program label,
as in TCD.s, or it can be the C function "main()". By default, no parameters are passed to main / main().


The Debugger and its Limitations

The debugger is useful -- you can set breakpoints and examine the code. However
if the free version of the Keil Development System, it only works
for the last file to be assembled or compiled! That is, you can only set breakpoints in one file,
and it has to be the last one -- the file whose filename is last in alphabetical order.
The debugger is of very limited use for debugging interrupts, but is quite useful for debugging
sections of code.


Using the Debugger

When you launch a program using the debugger, program execution automatically waits
at location 0x00000000. You should put a breakpoint on the instruction or statement
you want program execution to run to (which must be in alphabetically the last file
of the project, as mentioned above).

Then ask the debugger to run  (Debug > Run) the program. When program execution
reaches your breakpoint, the debugger will stop the program and you can single-step etc.
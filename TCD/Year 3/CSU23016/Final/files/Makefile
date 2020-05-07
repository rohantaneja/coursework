OBJS = ide.o console.o bio.o fs.o file.o swtch.o proc.o main.o\

sim : $(OBJS)
	cc -o sim $(OBJS)

%.o: %.c %.h
	cc -c -o $@ $<

clean :
	rm sim $(OBJS)

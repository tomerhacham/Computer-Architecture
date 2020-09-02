all: myELF

myELF: task2.o 
	gcc -m32 -g -Wall -o myELF task2.o 

task2.o: task2.c
	gcc -g -Wall -m32 -c -o task2.o task2.c

.PHONY: clean

clean: 
	rm -f *.o myELF

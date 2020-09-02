all: myELF

myELF: prgHDR.o 
	gcc -m32 -g -Wall -o myELF prgHDR.o 

prgHDR.o: prgHDR.c
	gcc -g -Wall -m32 -c -o prgHDR.o prgHDR.c

.PHONY: clean

clean: 
	rm -f *.o myELF

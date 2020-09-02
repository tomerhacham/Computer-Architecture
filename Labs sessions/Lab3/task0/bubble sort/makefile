#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: run

# Tool invocations
# Executable "lab3_bubblesort" depends on the files run.o
run: run.o
	gcc -g -m32 -Wall -o run run.o

# Depends on the source and header files
run.o: lab3_bubblesort.c
	gcc -m32 -g -Wall -c -o run.o lab3_bubblesort.c


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o run

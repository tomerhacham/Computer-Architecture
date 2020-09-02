#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: sigModifiy

# Tool invocations
sigModifiy: sigModifiy.o
	gcc -m32 -Wall -g -o sigModifiy sigModifiy.o

# Depends on the source and header files
sigModifiy.o: sigModifiy.c
	gcc -m32 -c -Wall -g -o sigModifiy.o sigModifiy.c
#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o sigModifiy

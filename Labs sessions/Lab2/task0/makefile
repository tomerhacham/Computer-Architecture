#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: count-words

# Tool invocations
count-words: count-words.o
	gcc -m32 -Wall -g -o count-words count-words.o

# Depends on the source and header files
count-words.o: count-words.c
	gcc -m32 -c -Wall -g -o count-words.o count-words.c
#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o count-words

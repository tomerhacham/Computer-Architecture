#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: addresses

# Tool invocations
addresses: addresses.o
	gcc -m32 -Wall -g -o addresses addresses.o

# Depends on the source and header files
addresses.o: addresses.c
	gcc -m32 -c -Wall -g -o addresses.o addresses.c
#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o addresses

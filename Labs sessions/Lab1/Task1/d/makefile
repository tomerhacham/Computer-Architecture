#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: encoder

# Tool invocations
# Executable "hello" depends on the files hello.o and run.o.
encoder: encoder.o
	gcc -m32 -o encoder encoder.o

# Depends on the source and header files
encoder.o: encoder.c
	gcc -m32 -c -o encoder.o encoder.c
#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o encoder

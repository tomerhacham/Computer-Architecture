#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: my_echo

# Tool invocations
# Executable "hello" depends on the files hello.o and run.o.
my_echo: my_echo.o
	gcc -m32 -o my_echo my_echo.o

# Depends on the source and header files
my_echo.o: my_echo.c
	gcc -m32 -c -o my_echo.o my_echo.c
#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o my_echo

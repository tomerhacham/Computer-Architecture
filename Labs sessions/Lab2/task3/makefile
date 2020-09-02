#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: menu

# Tool invocations
menu: menu.o
	gcc -m32 -Wall -g -o menu menu.o

# Depends on the source and header files
menu.o: menu.c
	gcc -m32 -c -Wall -g -o menu.o menu.c
#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o menu

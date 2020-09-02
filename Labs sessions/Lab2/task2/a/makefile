#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: menu_map

# Tool invocations
menu_map: menu_map.o
	gcc -m32 -Wall -g -o menu_map menu_map.o

# Depends on the source and header files
menu_map.o: menu_map.c
	gcc -m32 -c -Wall -g -o menu_map.o menu_map.c
#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o menu_map

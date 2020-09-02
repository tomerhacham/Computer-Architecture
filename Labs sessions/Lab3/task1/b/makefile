#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: virus_detection

# Tool invocations
menu: virus_detection.o
	gcc -m32 -Wall -g -o virus_detection virus_detection.o

# Depends on the source and header files
menu_map.o: virus_detection.c
	gcc -m32 -c -Wall -g -o virus_detection.o virus_detection.c
#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o virus_detection

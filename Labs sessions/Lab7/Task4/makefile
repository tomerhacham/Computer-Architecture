all: digit_cnt

digit_cnt: digit_cnt.o 
	gcc -m32 -g -Wall -o digit_cnt digit_cnt.o 

digit_cnt.o: digit_cnt.c
	gcc -g -Wall -m32 -fno-pie -c -o digit_cnt.o digit_cnt.c

.PHONY: clean

clean: 
	rm -f *.o digit_cnt

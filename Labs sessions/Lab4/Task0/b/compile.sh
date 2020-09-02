#!/bin/bash
nasm -f elf32 start.s -o start.o
gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector util.c -o util.o
gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector start.c -o main.o
ld -m elf_i386 start.o main.o util.o -o task0

#!/bin/bash
nasm -f elf32 lab4_start.s -o start.o
gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector lab4_util.c -o util.o
gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector lab4_main.c -o main.o
ld -m elf_i386 start.o main.o util.o -o task0

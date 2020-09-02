#!/bin/bash
gcc -m32 -c encoder.c -o encoder.o
gcc -m32 encoder.o -o run.out
./run.out


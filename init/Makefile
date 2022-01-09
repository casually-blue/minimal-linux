init: init.c
	gcc -fno-builtin -c -o init.o init.c -L../libc -lc
	gcc -fno-builtin -o init init.o -L../libc -lc

clean:
	rm -f init

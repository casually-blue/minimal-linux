SOURCES=src/printf.c \
	src/__libc_start_main.c \
	src/__stack_chk_fail.c \

OBJECTS=${SOURCES:.c=.o}

CFLAGS=
LDFLAGS=
CC=musl-gcc

all: libc.so

%.o: %.c
	$(CC) -nostdlib -c $(CFLAGS) $< -o $@

libc.so: $(OBJECTS)
	$(CC) -nostdlib -shared -o libc.so $(OBJECTS) $(LDFLAGS)

clean:
	rm -f $(OBJECTS) libc.so

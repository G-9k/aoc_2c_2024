CC=c99
CFLAGS=-Wall -Wextra -pedantic -O0 -g -lm -no-pie -z noexecstack
NASM=nasm
NASMFLAGS=-f elf64 -g -F DWARF

OUTPUT_PATH := ej1
OUTPUT_FILENAME := ej1
SRC_C := $(wildcard *.c)
SRC_ASM := $(wildcard *.asm)
HEADERS := $(wildcard *.h)
OBJS := $(patsubst %.c,%.o,$(SRC_C) $(patsubst %.asm,%.o,$(SRC_ASM)))

.PHONY: all valgrind clean

all: ej1

ej1: $(OBJS)
	$(CC) $(CFLAGS) $^ -o $(OUTPUT_FILENAME)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.asm $(HEADERS)
	$(NASM) $(NASMFLAGS) $< -o $@

valgrind: ej1
	valgrind --leak-check=full --track-origins=yes $(OUTPUT_FILENAME)

clean:
	rm -f *.o
	rm -rf $(OUTPUT_PATH)
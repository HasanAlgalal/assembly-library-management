.PHONY: all test clean
all: build/library

build/library: library.asm
	mkdir -p build
	nasm -f elf32 -o build/library.o library.asm
	ld -m elf_i386 -o build/library build/library.o

test: build/library
	python3 -m unittest discover -s tests -v

clean:
	rm -rf build

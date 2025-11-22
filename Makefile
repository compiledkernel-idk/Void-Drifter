all: game

game: main.o math.o data.o sound.o
	gcc -no-pie -o game main.o math.o data.o sound.o -lSDL2 -lm

main.o: main.asm
	nasm -f elf64 main.asm -o main.o

math.o: math.asm
	nasm -f elf64 math.asm -o math.o

data.o: data.asm
	nasm -f elf64 data.asm -o data.o

sound.o: sound.asm
	nasm -f elf64 sound.asm -o sound.o

clean:
	rm -f game *.o

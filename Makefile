all: game

game: main.o math.o data.o sound.o render.o update.o
	gcc -no-pie -o game main.o math.o data.o sound.o render.o update.o -lSDL2 -lSDL2_mixer -lm

main.o: main.asm
	nasm -O0 -f elf64 main.asm -o main.o

render.o: render.asm
	nasm -O0 -f elf64 render.asm -o render.o

update.o: update.asm
	nasm -O0 -f elf64 update.asm -o update.o

math.o: math.asm
	nasm -f elf64 math.asm -o math.o

data.o: data.asm
	nasm -f elf64 data.asm -o data.o

sound.o: sound.asm
	nasm -f elf64 sound.asm -o sound.o

clean:
	rm -f game *.o

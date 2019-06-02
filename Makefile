BIN = PROGRAM.COM

all: $(BIN)

run: $(BIN)
	dosbox ./$(BIN)

$(BIN): main.asm
	nasm main.asm -fbin -o $(BIN)

.PHONY: clean
clean:
	rm -rf $(BIN)


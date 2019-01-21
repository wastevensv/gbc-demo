TARGET=demo
SRCS=$(wildcard src/*.asm)
OBJS=$(patsubst src/%.asm, build/%.o, $(SRCS))

.SECONDARY: $(OBJS)

all: build/$(TARGET).gb

build/%.o: src/%.asm
	mkdir -p build/
	rgbasm -i src/ -p 0xff -o $@ $^

build/%.gb: $(OBJS)
	mkdir -p build/
	rgblink -p 0xff -n build/$*.sym -m build/$*.map -o $@ $(OBJS)
	rgbfix -Cjv -i XXXX -k XX -l 0x33 -m 0x05 -p 0 -r 1 -t $(TARGET) $@

clean:
	rm -r build/

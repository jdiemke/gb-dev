mkdir build
rgbasm -i src -o build/main.o src/main.asm
rgblink -o build/hello-world.gb build/main.o
rgbfix -v -p 0 build/hello-world.gb
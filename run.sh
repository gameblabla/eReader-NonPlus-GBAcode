rm *.ihx *.o *.z80 main.bin *.vpk *.lst *.sym loaderarm.bin arm.o

arm-none-eabi-as arm.asm -o arm.o
arm-none-eabi-objcopy -O binary arm.o loaderarm.bin

sdasz80 -l -o -s -p main.o main.asm
sdldz80  -n -- -i main.ihx main.o
makebin -p < main.ihx > main.z80
dd if=main.z80 of=main.bin bs=1 skip=256
./nevpk -i main.bin -o main.vpk -c -level 2
valgrind ./nedcmake -i main.vpk -o m.bin -region 0 -type 1 -name "HELLO" -header 0 -titlemode 0 -save 0
rm *.ihx *.o *.z80 main.bin *.vpk *.lst *.sym

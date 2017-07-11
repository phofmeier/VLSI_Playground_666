mkdir temp

UKM910-elf-as -as %1 -o temp/%1.o
UKM910-elf-ld --oformat binary temp/%1.o -o temp/%1.bin
bin2hex temp/%1.bin temp/%1.hex

copy temp\%1.hex memory.txt
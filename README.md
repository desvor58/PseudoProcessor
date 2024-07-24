# Pseudo Processor
(Sory for my English)\
(Documentation is my not strong side)\
Ok Its my own processor simulate.\
Its processor created based on processor from game "Turing Complite" and evry command in this processor represents one byte.\
First 2 bit on byte - command, others - arguments.\
\
Processor has 6 registers (size = 2 bytes), **ram** (size = 64 kbytes), input (1 byte) and output (1 byte)
\
This repo contains 2 files: *psd_proc.d* and *tbc.cpp*\
*psd_proc.d* - the process itself,\
*tbc.cpp* - convertor from **assembly language** (or **TBC language**) to byte commands

--------

# TBC guide
TBC contains 13 commands: 
1. rg0write - ***its not writble command*** it number which mov th rg0
   ``` asm
   63   # rg0 = 63
   mov rg0 rg1  # rg1  63
   ```
2. mov - move from first argument to second argument
   arguments:\
   I. rg0, rg1, rg2, rg3, rg4, rg5 - registers\
   II. in/out - input/output\
   III. mem - value from **ram**[rg5]\
   ``` asm
   mov rg0 rg1
   mov rg5 rg4
   mov in rg1
   mov rg1 out
   mov rg3 mem
   mov mem rg5
   ```
3. add - rg3 = rg1 + rg2
   ``` asm
   5
   mov rg0 rg1
   mov rg0 rg2
   add  # rg3 = 10
   ```
   next 7 commands has same sintax
5. sub - rg3 = rg1 - rg2
6. and - rg3 = rg1 && rg2
7. or  - rg3 = rg1 || rg2
8. xor - rg3 = rg1 ^ rg2
9. not - rg3 = !rg1
10. shr - rg3 = rg1 >> rg2
11. shl - rg3 = rg1 << rg2
12. jmp - jump to programm command no position from rg0
    ``` asm
    0x0000 5
    0x0001 mov rg0 rg1
    0x0002 mov rg1 rg2
    0x0003 add
    0x0004 0
    0x0005 jmp
    ```
14. jel - jump to programm command no position from rg0 if rg3 < 0
15. jeg - jump to programm command no position from rg0 if rg3 > 0
16. jez - jump to programm command no position from rg0 if rg3 = 0

# How compile
You can compile this any way you wan

For example
```
dmd src/psd_proc.d -of pp.exe
clang++ src/tbc.cpp -o tbc.exe
```

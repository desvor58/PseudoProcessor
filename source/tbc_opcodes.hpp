#include <iostream>
#include <map>

static const std::map<std::string, int> declaring_size_derectives {
    {"db", 1},
    {"dw", 2},
    {"dt", 3},
};

static const std::map<std::string, unsigned char> regs {
    {"zx",  0},
    {"ax",  1},
    {"bx",  2},
    {"cx",  3},
    {"dx",  4},
    {"fx",  5},
    {"in",  6},
    {"out", 6},
    {"mem", 7},
};

static const std::map<std::string, unsigned char> opcodes {
    {"mov",  0},
    {"wrt",  128},
    {"add",  1},
    {"addc", 129},
    {"sub",  2},
    {"subc", 130},
    {"and",  3},
    {"andc", 131},
    {"or",   4},
    {"orc",  132},
    {"not",  5},
    {"shr",  6},
    {"shrc", 134},
    {"shl",  7},
    {"shlc", 135},
    {"xor",  8},
    {"xorc", 136},
    
    {"jmp",  9},
    {"jmpc", 137},
    {"jez",  10},
    {"jezc", 138},
    {"jel",  11},
    {"jelc", 139},
    {"jeg",  12},
    {"jegc", 140},

    {"call", 13},
    {"ret",  14},
};
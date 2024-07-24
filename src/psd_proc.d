import std.stdio;
import std.file;

static const int MAX_FILE_SIZE = 1114112; // 2^17 + (15 * 2^16)

static ubyte input  = 0;
static ubyte output = 0;

static short rg0  = 0;
static short rg1  = 0;
static short rg2  = 0;
static short rg3  = 0;
static short rg4  = 0;
static ushort rg5 = 0;

static byte[65536] mem = 0;

// not best implementation, but best understandable
// I could do this with map (dictionary), but I not do :)
void set(int num, short val)
{
    switch (num) {
        case 0:
            rg0 = val;
            break;
        case 1:
            rg1 = val;
            break;
        case 2:
            rg2 = val;
            break;
        case 3:
            rg3 = val;
            break;
        case 4:
            rg4 = val;
            break;
        case 5:
            rg5 = val;
            break;
        case 6:
            output = cast(ubyte)val;
            break;
        case 7:
            mem[rg5] = cast(ubyte)val;
            break;

        default:
            return;
    }
}

short get(int num)
{
    switch (num) {
        case 0:
            return rg0;
        case 1:
            return rg1;
        case 2:
            return rg2;
        case 3:
            return rg3;
        case 4:
            return rg4;
        case 5:
            return rg5;
        case 6:
            return input;
        case 7:
            return mem[rg5];

        default:
            return 0;
    }
}

int main(string[] args)
{
    ubyte[] comms = cast(ubyte[])read(args[1], MAX_FILE_SIZE);

    for (uint i = 0; i < comms.length; i++) {
        ubyte c = comms[i];

        if (c < 64) {
            rg0 = c;
            continue;
        }
        if (c >= 64 && c < 128) {
            c -= 64;

            int arg1 = c / 8;
            c = c % 8;
            int arg2 = c;

            set(arg2, get(arg1));
            continue;
        }
        if (c >= 128 && c < 192) {
            c -= 128;

            if (c == 0) rg3 = cast(short)(rg1 + rg2);    // ADD
            if (c == 8) rg3 = cast(short)(rg1 - rg2);    // SUB
            if (c == 16) rg3 = cast(short)(rg1 && rg2);  // AND
            if (c == 24) rg3 = cast(short)(rg1 || rg2);  // OR
            if (c == 32) rg3 = cast(short)(rg1 ^^ rg2);  // XOR
            if (c == 40) rg3 = !rg1;                     // NOT
            if (c == 48) rg3 = cast(short)(rg1 >> rg2);  // SHR
            if (c == 56) rg3 = cast(short)(rg1 << rg2);  // SHL
            continue;
        }
        if (c >= 192) {
            c -= 192;

            if (c == 0) i = cast(uint)rg0;                 // JMP
            if (c == 16) if (rg3 < 0)  i = cast(uint)rg0;  // JEL
            if (c == 32) if (rg3 > 0)  i = cast(uint)rg0;  // JEG
            if (c == 48) if (rg3 == 0) i = cast(uint)rg0;  // JEZ
        }
    }

    writeln(input);
    writeln(output);
    writeln();
    writeln(rg0);
    writeln(rg1);
    writeln(rg2);
    writeln(rg3);
    writeln(rg4);
    writeln(rg5);

    return 0;
}
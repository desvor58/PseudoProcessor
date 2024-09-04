import std.stdio;
import std.file;
import std.format;
import core.stdc.stdlib;
import Dgame.Window;
import Dgame.Window.Event;
import Dgame.Graphic;
import Dgame.Math;

static const int MAX_FILE_SIZE = 1114112; // 2^17 + (15 * 2^16)

static const ushort CALL_REC_MAX_DEPTH = 4096;

static byte input  = 0;
static byte output = 0;

static short zx  = 0;  // zero
static short ax  = 0;
static short bx  = 0;
static short cx  = 0;
static short dx  = 0;
static ushort fx = 0;

static byte[65536] mem = 0;

void set(int num, short val);

short get(int num);

int main(string[] args)
{
    ubyte[] comms = cast(ubyte[])read(args[1], MAX_FILE_SIZE);
    
    ubyte[] data;
    if (args.length > 2) {
        if (args[2] != "none") {
            data = cast(ubyte[])read(args[2], MAX_FILE_SIZE);
        }
    }

    string debug_endout = "";
    if (args.length > 3) {
        debug_endout = args[3];
    }

	bool graphic_mode = false;
    if (args.length > 4) {
        if (args[4] == "gmode") {
            graphic_mode = true;
        }
    }

    ushort gmode_width  = 0;
    ushort gmode_height = 0;

    ubyte gmode_colR = 0;
    ubyte gmode_colG = 0;
    ubyte gmode_colB = 0;

    short gmode_pointX = 0;
    short gmode_pointY = 0;

    Event gmode_event;
    Window win;

    int datacounter = 0;
    short ext_code = 0;

    ushort[CALL_REC_MAX_DEPTH] call_ret_address_stack;
    int call_ret_address_SP = -1;

    for (int i = 0; i < comms.length; i += 4) {
        ubyte comm = comms[i];
        ubyte arg1 = comms[i + 1];
        ubyte arg2 = comms[i + 2];
        ubyte retx = comms[i + 3];
        
        if (debug_endout == "debug") {
            writeln(format("command: %X", i));
        }

        // mov
        if (comm == 0) {
            set(arg1, get(arg2));
        }
        // movc - second argument - constant literal
        if (comm == 128) {
            set(arg1, cast(short)(retx + arg2 * 256));
        }

        // add
        if (comm == 1) {
            set(arg1, cast(short)(get(arg1) + get(arg2)));
        }
        // addc
        if (comm == 129) {
            set(arg1, cast(short)(get(arg1) + (arg2*256 + retx)));
        }

        // sub
        if (comm == 2) {
            set(arg1, cast(short)(get(arg1) - get(arg2)));
        }
        // subc
        if (comm == 130) {
            set(arg1, cast(short)(get(arg1) - (arg2*256 + retx)));
        }

        // and
        if (comm == 3) {
            set(arg1, cast(short)(get(arg1) && get(arg2)));
        }
        // andc
        if (comm == 131) {
            set(arg1, cast(short)(get(arg1) && (arg2*256 + retx)));
        }

        // or
        if (comm == 4) {
            set(arg1, cast(short)(get(arg1) || get(arg2)));
        }
        // orc
        if (comm == 132) {
            set(arg1, cast(short)(get(arg1) || (arg2*256 + retx)));
        }

        // not
        if (comm == 5) {
            set(arg1, cast(short)(!get(arg1)));
        }

        // shr
        if (comm == 6) {
            set(arg1, cast(short)(get(arg1) >> get(arg2)));
        }
        // shrc
        if (comm == 134) {
            set(arg1, cast(short)(get(arg1) >> (arg2*256 + retx)));
        }

        // shl
        if (comm == 7) {
            set(arg1, cast(short)(get(arg1) << get(arg2)));
        }
        // shlc
        if (comm == 135) {
            set(arg1, cast(short)(get(arg1) << (arg2*256 + retx)));
        }

        // xor
        if (comm == 8) {
            set(arg1, cast(short)(get(arg1) ^^ get(arg2)));
        }
        // xorc
        if (comm == 136) {
            set(arg1, cast(short)(get(arg1) ^^ (arg2*256 + retx)));
        }

        // jmp
        if (comm == 9) {
            i = get(arg1) - 4;
        }
        // jmpc
        if (comm == 137) {
            i = cast(short)(arg2 + arg1 * 256) - 4;
        }

        // jez
        if (comm == 10) {
            if (get(arg1) == 0) {
                i = get(arg2) - 4;
            }
        }
        // jezc
        if (comm == 138) {
            if (get(arg1) == 0) {
                i = cast(short)(retx + arg2 * 256) - 4;
            }
        }

        // jel
        if (comm == 11) {
            if (get(arg1) < 0) {
                i = get(arg2) - 4;
            }
        }
        // jelc
        if (comm == 139) {
            if (get(arg1) < 0) {
                i = cast(short)(retx + arg2 * 256) - 4;
            }
        }

        // jeg
        if (comm == 12) {
            if (get(arg1) > 0) {
                i = get(arg2) - 4;
            }
        }
        // jegc
        if (comm == 140) {
            if (get(arg1) > 0) {
                i = cast(short)(retx + arg2 * 256) - 4;
            }
        }

        // call
        if (comm == 13) {
            call_ret_address_SP++;
            writeln(call_ret_address_SP);
            call_ret_address_stack[call_ret_address_SP] = cast(ushort)i;
            i = cast(short)(arg2 + arg1 * 256) - 4;
        }

        // ret
        if (comm == 14) {
            i = call_ret_address_stack[call_ret_address_SP];
            call_ret_address_stack[call_ret_address_SP] = 0;
            call_ret_address_SP--;
        }

        if (debug_endout == "debug") {
            writeln(input);
            writeln(output);
            writeln();
            writeln(zx);
            writeln(ax);
            writeln(bx);
            writeln(cx);
            writeln(dx);
            writeln(fx);

            readln();
        }

        input = 0;
        
        if (args.length > 2) {
            if (output == 1) {
                if (datacounter < data.length) {
                    input = data[datacounter];
                }
            }
        }
        if (output == 1) {
            datacounter++;
        }
        if (output == -1) {
            ext_code = zx;
            goto end;
        }

        if (graphic_mode == true) {
            if (output == 2) {
                gmode_width  = ax;
                gmode_height = bx;
            }
            if (output == 3) {
                win = Window(gmode_width, gmode_height, "PPWindow");
            }
            if (output == 4) {
                win.clear();
            }
            if (output == 5) {
                win.display();
            }
            if (output == 6) {
                win.setClearColor(Color4b(cast(ubyte)ax, cast(ubyte)bx, cast(ubyte)cx));
            }
        }
        
        output = 0;
    }

end:
    if (debug_endout == "endout") {
        writeln(input);
        writeln(output);
        writeln();
        writeln(zx);
        writeln(ax);
        writeln(bx);
        writeln(cx);
        writeln(dx);
        writeln(fx);
    }

    exit(ext_code);
}

void set(int num, short val)
{
    switch (num) {
        case 0:
            zx = val;
            break;
        case 1:
            ax = val;
            break;
        case 2:
            bx = val;
            break;
        case 3:
            cx = val;
            break;
        case 4:
            dx = val;
            break;
        case 5:
            fx = val;
            break;
        case 6:
            output = cast(byte)val;
            break;
        case 7:
            mem[fx] = cast(byte)val;
            break;

        default:
            return;
    }
}

short get(int num)
{
    switch (num) {
        case 0:
            return zx;
        case 1:
            return ax;
        case 2:
            return bx;
        case 3:
            return cx;
        case 4:
            return dx;
        case 5:
            return fx;
        case 6:
            return input;
        case 7:
            return mem[fx];

        default:
            return 0;
    }
}

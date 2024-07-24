#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <map>

std::vector<std::string> split(std::string str, const char splitter)
{
    std::vector<std::string> res;
    std::string buf;

    for (const char c : str) {
        if (c == splitter) {
            if (buf != "") {
                res.push_back(buf);
                buf = "";
            }
            continue;
        }
        buf += c;
    }
    res.push_back(buf);

    return res;
}

bool sisd(std::string s)
{
    for (char c : s) {
        if (!isdigit(c)) {
            return false;
        }
    }
    return true;
}

std::string signore(std::string s, char cign) {
    std::string res;
    for (char c : s) {
        if (c == cign) continue;
        res += c;
    }

    return res;
}

int main(int argc, char **args)
{
    if (argc < 3) {
        exit(EXIT_FAILURE);
    }

    std::ifstream file(args[1]);
    if (!file.is_open()) {
        exit(EXIT_FAILURE);
    }

    char fc;
    std::string str;
    std::vector<std::string> strs;
    while (file.get(fc)) {
        if (fc == '\n') {
            strs.push_back(str);
            str = "";
            continue;
        }
        str += fc;
    }
    strs.push_back(str);
    file.close();

    unsigned char c = 0;
    std::vector<char> comms {};

    std::map<std::string, int> labels {};

    std::ofstream ofile(args[2], std::ios::out | std::ios::binary);
    if (!ofile.is_open()) {
        std::cerr << "ERROR" << std::endl;
        exit(EXIT_FAILURE);
    }

    int i = 0;

    for (std::string str : strs) {
        std::vector<std::string> sstr = split(str, ' ');
        if (sstr[0][0] == '$') {
            labels[signore(sstr[0], '$')] = i;
            goto commentL;
        }
    }

    for (std::string str : strs) {
        c = 0;

        std::vector<std::string> sstr = split(str, ' ');

        if (sstr[0][0] == '#' || str.empty()) {
            goto commentL;
        }
        if (labels.count(sstr[0]) > 0) {
            c += labels[sstr[0]];
        }
        if (sisd(sstr[0])) {
            c += std::stoi(sstr[0]);
            i++;
        }
        if (sstr[0] == "mov") {
            c += 64;

            if (sstr[1] == "rg1") c += 8;
            if (sstr[1] == "rg2") c += 16;
            if (sstr[1] == "rg3") c += 24;
            if (sstr[1] == "rg4") c += 32;
            if (sstr[1] == "rg5") c += 40;
            if (sstr[1] == "in")  c += 48;
            if (sstr[1] == "mem") c += 56;

            if (sstr[2] == "rg1") c += 1;
            if (sstr[2] == "rg2") c += 2;
            if (sstr[2] == "rg3") c += 3;
            if (sstr[2] == "rg4") c += 4;
            if (sstr[2] == "rg5") c += 5;
            if (sstr[2] == "out") c += 6;
            if (sstr[2] == "mem") c += 7;
            
            i++;
        }

        if (sstr[0] == "add") {c += 128;      i++;}
        if (sstr[0] == "sub") {c += 128 + 8;  i++;}
        if (sstr[0] == "and") {c += 128 + 16; i++;}
        if (sstr[0] == "or")  {c += 128 + 24; i++;}
        if (sstr[0] == "xor") {c += 128 + 32; i++;}
        if (sstr[0] == "not") {c += 128 + 40; i++;}
        if (sstr[0] == "shr") {c += 128 + 48; i++;}
        if (sstr[0] == "shl") {c += 128 + 56; i++;}

        if (sstr[0] == "jmp") {c += 192;      i++;}
        if (sstr[0] == "jel") {c += 192 + 16; i++;}
        if (sstr[0] == "jeg") {c += 192 + 32; i++;}
        if (sstr[0] == "jez") {c += 192 + 48; i++;}

        comms.push_back(c);
commentL:
    }

    for (char c : comms) {
        std::cout << +c << std::endl;
    }

    ofile.write(&comms[0], comms.size());
    ofile.close();

    return 0;
}
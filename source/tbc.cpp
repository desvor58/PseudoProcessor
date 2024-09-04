#include <iostream>
#include <fstream>
#include <vector>
#include <string>

#include "tbc_opcodes.hpp"

std::vector<std::string> split(std::string str, const char splitter);

bool sisd(std::string s);

std::string signore(std::string s, char cign);

std::vector<std::string> sins(std::vector<std::string> v1, std::vector<std::string> v2, int index);

std::vector<std::string> get_file_lines(std::string file_name);

std::map<std::string, unsigned int> lables {};

int main(int argc, char **argv)
{
    if (argc < 3) {
        std::cerr << "Error: Expect file names" << std::endl;
        exit(EXIT_FAILURE);
    }

    std::vector<std::string> strs = get_file_lines(argv[1]);

    char comm[4] {0, 0, 0, 0};
    int comm_index = 0;

    std::vector<char> comms {};

    int declaring_size = 1;  // in bytes
    
    unsigned int nocompile_lines = 0;

    for (int i = 0; i < strs.size(); i++) {
        std::string str = strs[i];
        std::vector<std::string> sstr = split(str, ' ');

        for (int j = 0; j < sstr.size(); j++) {
            std::string part = sstr[j];

            if (part[part.length() - 1] == ':') {
                lables[signore(part, ':')] = i - nocompile_lines;
                nocompile_lines++;
                continue;
            }
        }
    }

    for (int i = 0; i < strs.size(); i++) {
        std::string str = strs[i];
        std::vector<std::string> sstr = split(str, ' ');

        for (int j = 0; j < sstr.size(); j++) {
            std::string part = sstr[j];

            if (lables.count(part) > 0) {
                sstr[j] = std::to_string(lables.at(part) * 4);
                continue;
            }
        }

        std::string res_str = "";

        for (std::string p : sstr) {
            res_str += p;
            res_str += ' ';
        }

        strs[i] = res_str;
    }

    for (std::string str : strs) {
        //std::cout << str << std::endl;
    }

    for (int i = 0; i < strs.size(); i++) {
        comm[0] = 0;
        comm[1] = 0;
        comm[2] = 0;
        comm[3] = 0;

        comm_index = 0;

        std::string str = strs[i];
        std::vector<std::string> sstr = split(str, ' ');

        declaring_size = 2;

        for (int j = 0; j < sstr.size(); j++) {
            std::string part = sstr[j];
            //std::cout << part << std::endl;

            if (part[0] == ';') {
                goto coment_end;
            }
            if (declaring_size_derectives.count(part) > 0) {
                declaring_size = declaring_size_derectives.at(part);
                continue;
            }
            if (sisd(part)) {
                char np1;
                char np2;

                if (declaring_size == 1) {
                    comm[comm_index] = std::stoi(part);
                    comm_index++;
                    continue;
                }
                if (declaring_size == 2) {
                    int offset = std::stoi(part) / 256;
                    np2 = offset;
                    np1 = std::stoi(part) - offset * 256;

                    comm[comm_index] = np2;
                    comm[++comm_index] = np1;
                    continue;
                }
            }
            if (regs.count(part) > 0) {
                comm[comm_index] = regs.at(part);
                comm_index++;
                continue;
            }
            if (opcodes.count(part) > 0) {
                if (j + 2 < sstr.size() || j + 1 < sstr.size()) {
                    if (sisd(sstr[j + 1]) || sisd(sstr[j + 2])) {
                        if (part != "call") {
                            comm[comm_index] = opcodes.at(part) + 128;
                            goto opcodeWRT;
                        }
                    }
                }
                comm[comm_index] = opcodes.at(part);
opcodeWRT:      comm_index++;
                continue;
            }
            else {
                goto end;
            }
        }
coment_end:
        for (char c : comm) {
            comms.push_back(c);
        }
end:
    }

    std::ofstream ofile(argv[2], std::ios::binary);
    ofile.write(&comms[0], comms.size());
    ofile.close();

    for (auto l : lables) {
        std::cout << l.first << ", " << l.second << std::endl;
    }

    return 0;
}

std::vector<std::string> split(std::string str, const char splitter)
{
    std::vector<std::string> ss;
    std::string buf;

    for (const char c : str) {
        if (c == splitter) {
            if (buf != "") {
                ss.push_back(buf);
                buf = "";
            }
            continue;
        }
        buf += c;
    }
    ss.push_back(buf);

    std::vector<std::string> res {};

    for (std::string s : ss) {
        if (s.empty()) {
            continue;
        }
        res.push_back(s);
    }

    return res;
}

bool sisd(std::string s)
{
    if (s.empty()) return false;

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

std::vector<std::string> get_file_lines(std::string file_name)
{
    std::ifstream file(file_name);
    if (!file.is_open()) {
        std::cerr << "Error: File not be open" << std::endl;
        exit(EXIT_FAILURE);
    }

    char c;
    std::string s;
    std::vector<std::string> strs1 {};

    while (file.get(c)) {
        if (c == '\n') {
            strs1.push_back(s);
            s = "";
            continue;
        }
        s += c;
    }
    strs1.push_back(s);
    file.close();

    std::vector<std::string> strs2 {};

    for (std::string str : strs1) {
        if (str == "") {
            continue;
        }
        strs2.push_back(str);
    }

    return strs2;
}
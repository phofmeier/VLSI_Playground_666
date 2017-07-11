# Name:          build.py
# Author:        Nicholas Feix <nf-uni@fconsoft.com>
# Creation Date: 2017-06-06


import subprocess
import time
import os
import sys

TOOL_PATH = "C:\\NICKI\\Studium\\Semester 8\\VLSI\\Project\\UKM910DevelopmentTools\\UKM910Tools"

os.environ["PATH"] += ";" + TOOL_PATH

def replace_tabs(s, num_spaces=4):
    result = ""
    split  = s.split("\t")
    for c in split[:-1]:
        result += c
        result += ' ' * (num_spaces - len(result) % num_spaces)
    result += split[-1]
    return result

def build(filename):
    cmd    = ["build.bat", filename]
    pipe   = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    symbols = {}
    while 42:
        line = pipe.stdout.readline()
        if not line:
            break
        sys.stdout.write(line)
        if line.strip().startswith(filename):
            split = line.split(".text:")
            if len(split) != 2:
                continue
            progline = int(split[0].rsplit(":")[-1].strip())
            split = split[1].split(" ")
            lnum = int(split[0], 16) >> 1
            sym = symbols.get(lnum, [progline])
            sym[0] = progline
            sym.append(split[1].strip(" \t\r\n"))
            symbols[lnum] = sym
    code = open(filename, "rb").readlines()
    lines = open("memory.txt", "rb").readlines()
    newline = lines[0].endswith("\r\n") and "\r\n" or "\n"
    base = j = 0
    for i in range(len(lines)):
        if i in symbols:
            keep = ""
            base = symbols[i][0]
            j    = -1
        while 42:
            if (base + j + 2) == len(code):
                break
            codeline = code[base + j].rstrip("\r\n \t")
            j += 1
            temp = codeline.split("#")[0].strip(" \t")
            if temp.endswith(":"):
                keep = " ".join([keep, codeline.lstrip(" \t")])
            elif temp:
                if keep:
                    codeline = (" ".join([keep, codeline.lstrip(" \t")]))[1:]
                keep = ""
                break
        if "\t" in codeline:
            codeline = replace_tabs(codeline, 8)
        lines[i] = " ".join([lines[i][:4], ";", codeline]) + newline
    open("memory.txt", "wb").writelines(lines)


if __name__ == "__main__":
    build(sys.argv[1])

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
    cmd    = ["build_array.bat", filename]
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

if __name__ == "__main__":
    build(sys.argv[1])

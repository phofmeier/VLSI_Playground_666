# Name:          convert_splash.py
# Author:        Nicholas Feix <nf-uni@fconsoft.com>
# Creation Date: 2017-06-08


import binascii
import sys

DIMENSION = (80, 40)

def convert(filename):
    lines = open(filename, "rb").readlines()
    arr = []
    for line in lines[:DIMENSION[1]]:
        conv = binascii.hexlify(line.strip("\r\n")[:DIMENSION[0]].ljust(DIMENSION[0]))
        for i in range(0, min(DIMENSION[0]*2, len(conv)), 4):
            arr.append('x"%s",' %conv[i:i+4])
    arr.extend(['x"2020",'] * ((DIMENSION[0] * DIMENSION[1] / 2) - len(arr)))
    data = "\n".join(" ".join(arr[i:i+20]) for i in range(0, len(arr), 20))
    open("splash.array", "wb").write(data)


if __name__ == "__main__":
    convert(sys.argv[1])

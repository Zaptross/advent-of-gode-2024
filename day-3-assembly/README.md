# Day 3 - Assembly

[Home](../README.md)

## Setup

Following the guide on [StackOverflow](https://askubuntu.com/a/1064622)

```sh
# as31 is an intel 8031/8051 assembler
# nasm is a general purpose x86 assembly compiler
sudo apt install as31 nasm
```

## Build

To build the program, either:

```sh
# from the repo root
make day3
```

Or:

```sh
# in the day-3-assembly directory
nasm -f elf64 day3.asm && \
ld -s -o day3 day3.o
```

To run the example, run the binary and type the file name to use:
Eg:

```sh
./day3
# typed once the program starts:
example.txt
```

Or pipe the filename to the binary:

```sh
echo example.txt | day3
```

## Docs

- []()

# Day 1 - Cobol

[Home](../README.md)

## Setup

Following the general principles from [this stackoverflow thread](https://askubuntu.com/questions/287180/how-to-compile-and-run-a-cobol-program) do the following:

```sh
# opencobol was later renamed to gnucobol
sudo apt install gnucobol3
```

## Build

To build the program, either:

```sh
# from the repo root
make day1
```

Or:

```sh
# in the day-1-cobol directory
cobc -free -x -o day1-cobol day1.cbl
```

To compile for the example data use the flag:

```sh
-D EXAMPLE=1
```

To compile for part 2 use the flag:

```sh
-D PART_N=2
```

Eg:

```sh
cobc -free -D EXAMPLE=1 -D PART_N=2 -x -o day1-cobol day1.cbl
```

## Docs

- [Mainframes Tech Help COBOL](https://www.mainframestechhelp.com/tutorials/cobol/introduction.htm)
- [GnuCOBOL Manual](https://gnucobol.sourceforge.io/doc/gnucobol.html)

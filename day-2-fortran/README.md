# Day 2 - Fortran

[Home](../README.md)

## Setup

Following the guide at [fortran-lang.org](https://fortran-lang.org/en/learn/os_setup/install_gfortran/)

```sh
# gfortran is the GNU Fortran project
sudo apt install gfortran
```

## Build

To build the program, either:

```sh
# from the repo root
make day2
```

Or:

```sh
# in the day-1-cobol directory
gfortran day2.f90 -o d2p1
```

To run the example, either run the binary and type the file name to use:
Eg:

```sh
./d2p1
# typed once the program starts:
example.txt
```

Or pipe the filename to the binary:

```sh
echo example.txt | d2p1
```

## Docs

- [fortran-lang.org](https://fortran-lang.org/en/learn/)

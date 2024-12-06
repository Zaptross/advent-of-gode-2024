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
# in the day-2-fortran directory
gfortran day2.f90 -o day2
```

To run the example, either run the binary and type the file name to use:
Eg:

```sh
./day2
# typed once the program starts:
example.txt
```

Or pipe the filename to the binary:

```sh
echo example.txt | day2
```

## Docs

- [fortran-lang.org](https://fortran-lang.org/en/learn/)

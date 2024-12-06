all: day1 day2 day3
clean: cleand1 cleand2 cleand3

# DAY 1 - COBOL
day1: day-1-cobol/d1p1e day-1-cobol/d1p1 day-1-cobol/d1p2e day-1-cobol/d1p2
.PHONY: day-1-cobol/d1p1e day-1-cobol/d1p1 day-1-cobol/d1p2e day-1-cobol/d1p2
cleand1:
	rm day-1-cobol/d1p1e; \
	rm day-1-cobol/d1p1; \
	rm day-1-cobol/d1p2e; \
	rm day-1-cobol/d1p2


# each target here builds a version of the binary, as COBOL
# can't take command line arguments at runtime, so we pass
# two DEFINE flags at compile time to control behaviour
day-1-cobol/d1p1e: day-1-cobol/day1.cbl
	cd day-1-cobol &&	\
	cobc -free -D EXAMPLE=1 -x -o d1p1e day1.cbl && \
	./d1p1e
day-1-cobol/d1p1: day-1-cobol/day1.cbl
	cd day-1-cobol &&	\
	cobc -free -x -o d1p1 day1.cbl && \
	./d1p1
day-1-cobol/d1p2e: day-1-cobol/day1.cbl
	cd day-1-cobol &&	\
	cobc -free -D PART_N=2 -D EXAMPLE=1 -x -o d1p2e day1.cbl && \
	./d1p1e
day-1-cobol/d1p2: day-1-cobol/day1.cbl
	cd day-1-cobol &&	\
	cobc -free -D PART_N=2 -x -o d1p2 day1.cbl && \
	./d1p1

# DAY 2 - FORTRAN
day2: day-2-fortran/day2
.PHONY: day-2-fortran/day2
cleand2:
	rm day-2-fortran/day2

day-2-fortran/day2: day-2-fortran/day2.f90
	cd day-2-fortran && \
	gfortran day2.f90 -o day2 && \
	echo "example.txt" | ./day2 && \
	echo "input.txt" | ./day2

# DAY 3 - ASSEMBLY
day3: day-3-assembly/day3
.PHONY: day-3-assembly/day3
cleand3:
	rm day-3-assembly/day3

day-3-assembly/day3: day-3-assembly/day3.asm
	cd day-3-assembly && \
	nasm -f elf64 day3.asm && \
	ld -s -o day3 day3.o && \
	./day3

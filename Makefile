all: day1 day2
clean: cleand1 cleand2

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

day2: day-2-fortran/day2
.PHONY: day-2-fortran/day2
cleand2:
	rm day-2-fortran/day2

day-2-fortran/day2: day-2-fortran/day2.f90
	cd day-2-fortran && \
	gfortran day2.f90 -o day2 && \
	echo "example.txt" | ./day2 && \
	echo "input.txt" | ./day2

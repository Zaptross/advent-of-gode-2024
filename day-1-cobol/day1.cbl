IDENTIFICATION DIVISION.
PROGRAM-ID. AOC-COBOL-DAY-1.
AUTHOR. M. Price (Zaptross).
DATE-WRITTEN. 2024-12-03.
INSTALLATION. Ubuntu22.04-GnuCOBOL.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT input-file ASSIGN TO FILE_IN
    ORGANISATION IS LINE SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD input-file.
01 frow.
$IF EXAMPLE DEFINED
    $DISPLAY EXAMPLE MODE
    05 lnum PIC X(1).
    05 FILLER PIC X(3) VALUE SPACES.
    05 rnum PIC X(1).
$ELSE
    05 lnum PIC X(5).
    05 FILLER PIC X(3) VALUE SPACES.
    05 rnum PIC X(5).
$END

WORKING-STORAGE SECTION.
*> PART_N and PART are used to determine which part we're undertaking
$IF PART_N > 1
    78 PART VALUE 2.
    $DISPLAY PART 2
$ELSE
    78 PART VALUE 1.
    $DISPLAY PART 1
$END
*> EXAMPLE is used to toggle between the example input to verify results
*> and the actual input to calculate our answer from
$IF EXAMPLE DEFINED
    *> If example, set the file to open, number of rows to 6, and digits to 1
    01 FILE_IN PIC X(12) VALUE "example.txt".
    78 FILE_LEN VALUE 6.
    01 arr1.
        05 colLeft PIC 9(1) OCCURS FILE_LEN TIMES.
    01 arr2.
        05 colRight PIC 9(1) OCCURS FILE_LEN TIMES.
$ELSE
    *> If not example, set the file to open, number of rows to 1000, and digits to 5
    01 FILE_IN PIC X(9) VALUE "input.txt".
    78 FILE_LEN VALUE 1000.
    01 arr1.
        05 colLeft PIC 9(5) OCCURS FILE_LEN TIMES.
    01 arr2.
        05 colRight PIC 9(5) OCCURS FILE_LEN TIMES.
$END
01 str PIC X(20). *> used for string formatting
01 RES_TX PIC X(15) VALUE "RESULT:". *> used for formatting result string
01 i PIC 9999 VALUE 1. *> used as reusable loop invariant
01 feof PIC A(1). *> used for detecting end of file
01 res PIC 99999999 VALUE 0. *> used for storing the final result

*> used for calculating difference in part 1
01 diff PIC 99999 VALUE 0.
*> used for calculating similarity in part 2
01 target_num PIC 99999.
01 target_count PIC 99999 VALUE 0.
01 target_idx PIC 99999 VALUE 1.


PROCEDURE DIVISION.
    *> Start of main()
    OPEN INPUT input-file.
    PERFORM read-line UNTIL feof='Y'.
    CLOSE input-file.

    SORT colLeft ON ASCENDING.
    SORT colRight ON ASCENDING.

*> for debugging, include an option to check the input post sorting
$IF DEBUG DEFINED
    PERFORM print-input.
$END

    *> Switch between part 1 and 2, and print out the result
    IF PART = 1
      PERFORM calc-diff
    ELSE
      PERFORM calc-similarity
    END-IF
    PERFORM print-res

    STOP RUN.
    *> End of main()

read-line.
    *> Handle reading the entire file line by line
    READ input-file
        AT END MOVE 'Y' to feof
        NOT AT END PERFORM store-element
    END-READ.

store-element.
    *> Store the numbers from the current row of the file to arrays
    MOVE lnum TO colLeft(i).
    MOVE rnum to colRight(i).
    COMPUTE i = i + 1.

print-input.
    *> Print out each row of the input file read in.
    PERFORM VARYING i FROM 1 BY 1 UNTIL i > FILE_LEN - 1
        STRING colLeft(i), SPACE, colRight(i) INTO str
        DISPLAY str
    END-PERFORM.

calc-diff.
    *> For each pair, add the absolute difference to the result
    *> eg. 1   4  -> diff: -3 -> abs: 3 -> result += 3
    PERFORM VARYING i FROM 1 BY 1 UNTIL i > FILE_LEN
        COMPUTE diff = colLeft(i) - colRight(i)
        IF diff < 0
            COMPUTE diff = -diff
        END-IF
        COMPUTE res = res + diff
    END-PERFORM.

print-res.
    *> Nicely format and print the result, eg:
    *> RESULT:
    *> 123
    STRING RES_TX, SPACE, res INTO RES_TX.
    DISPLAY RES_TX.
    DISPLAY res.

calc-similarity.
    PERFORM VARYING i FROM 1 BY 1 UNTIL i > FILE_LEN
        IF NOT target_num = colLeft(i)
          COMPUTE target_num = colLeft(i)
          PERFORM count-target
        END-IF
        COMPUTE res = res + target_num * target_count
    END-PERFORM.

count-target.
    *> Reset count each time
    COMPUTE target_count = 0.

    *> Increment target count for each matching number
    *> Stop counting when number exceeds target
    *> This relies upon the arrays being sorted ascending
    PERFORM VARYING target_idx FROM target_idx BY 1 UNTIL colRight(target_idx) > target_num OR target_idx > FILE_LEN
        IF colRight(target_idx) = target_num
            COMPUTE target_count = target_count + 1
        END-IF
    END-PERFORM.


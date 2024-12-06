program day2
  ! from the intrinsic library, import the end of file (EOF) status
  use, intrinsic :: iso_fortran_env, only : iostat_end
  implicit none

  ! declare variables for reading in the file line by line
  logical :: file_exists
  integer :: file_handle, error
  character(20) :: filepath
  character(24) :: raw_line

  ! declare variables for parsing the lines into arrays of integers
  integer :: i, j, k, parsed_num
  character(4) :: parse_char
  integer, dimension(7) :: row

  ! declare variables for counting the results
  integer :: safe, safe_count, safe_problem_damped

  ! declare that we're using our functions below. the type must match the
  ! function return type, and the name must match
  integer :: is_safe
  integer :: problem_dampener

  safe_count = 0
  safe_problem_damped = 0

  ! read text input from stdin - either piped or manually entered works
  read(*,*) filepath

  ! first check that the file exists, then process it if so
  inquire(file=filepath, exist=file_exists)
  if (file_exists) then

    ! open the file in line by line readonly mode
    open(newunit=file_handle, file=trim(filepath), access='sequential', status='old', action='read')

    do
      ! reset our variables at the start of the loop to ensure a clean slate for
      ! parsing each line of the input file
      parse_char = ''
      i = 1
      j = 1
      k = 1
      row = [0,0,0,0,0,0,0]

      ! read a line of the file in entire line string mode `(A)`
      ! Fortran is quite good at reading tabular data, as long as the rows within
      ! each table have a consistent number of columns.
      ! eg, in the example input we always have 5 numbers per row so the following
      !     quite nicely captures the input data as an array of 5 integers:
      ! 
      !     integer, dimension(5) :: line
      !     read(file_handle, *) line
      !
      ! because the non-example input has rows of *varying* length, we need to
      ! manually parse out the numbers from the line by scanning through the
      ! characters and building each number
      read(file_handle, '(A)', iostat = error) raw_line


      ! when we read each line, we need to check if we've had an error or hit eof
      if (error == iostat_end) then
        ! if we hit end of file, exit the loop
        exit
      else if (error /= 0) then
        ! if there was an error, log it and exit
        print *, "error reading file", error
        exit
      end if

      ! after checking for read errors or eof, process the line data

      ! trim any preceding or trailing whitespace, just in case
      raw_line = trim(raw_line)

      ! for each character in the string, check if it is not a space and add it
      ! to the parse_char string, to later parse into an int
      do i = 1, len(raw_line), 1

        ! if this character is a space we're between numbers, so we can
        ! parse the char and add it to the row
        if (raw_line(i:i) == ' ') then
          ! if it's not an empty parse_char string
          if (len(parse_char) > 0) then

            ! treat the string as an "internal file" and read the value out as
            ! an integer. this is the idiomatic way to parse integers
            read(parse_char, '(i4)') parsed_num

            ! if the parsed character succeeded, it should be > 0, and we can
            ! add it to the row, then move our pointer to the next element
            ! of the row ready to insert the next number
            if (parsed_num > 0) then
              row(k:k) = parsed_num
              k = k + 1
            end if
          end if

          ! reset variables after parsing and adding the character
          j = 1
          parse_char = ''
        else

          ! if it's not a space it must be a digit, so add it to the parse_char
          ! string, and move the pointer to the next element of the parse_char
          parse_char(j:j) = raw_line(i:i)
          j = j + 1
        end if
      end do

      ! after parsing a row check if it is safe for part 1
      safe = is_safe(row, k - 1)
      if (safe == 0) then
        safe_count = safe_count + 1
      end if

      ! then check if it is handled by the problem dampener for part 2
      safe = problem_dampener(row, k - 1)
      if (safe == 0) then
        safe_problem_damped = safe_problem_damped + 1
      end if
    end do

    close(file_handle)
  end if

  ! lastly, print out the results
  print *, "Using data: ", filepath
  print *, "Part 1 - safety checks", safe_count
  print *, "Part 2 - problem damping", safe_problem_damped

end program day2

integer function problem_dampener(row, count) result(safe)
  ! These are allocating the function args, and `intent(in)` denotes them as
  ! read only, so they cannot be reassigned 
  integer, dimension(7), intent(in) :: row
  integer, intent(in) :: count
  integer, dimension(7) :: remove_single
  integer :: is_safe
  integer :: i, j, k

  safe = is_safe(row, count)

  if (safe /= 0) then
    to_remove : do i = 1, count, 1
      ! reset for next try
      remove_single = [0,0,0,0,0,0,0]
      k = 1

      ! fill remove_single from row, skipping at i
      do j = 1, count, 1
        if (j /= i) then
          remove_single(k:k) = row(j:j)
          k = k + 1
        end if
      end do

      ! because we're removing one element, we need to run is_safe on the smaller set
      safe = is_safe(remove_single, count - 1)

      ! if one variation of removing a single number makes it safe
      ! exit the to_remove loop
      if (safe == 0) then
        exit
      end if
    end do to_remove
  end if

end function problem_dampener

integer function is_safe(row, count) result(safe)
  ! These are allocating the function args, and `intent(in)` denotes them as
  ! read only, so they cannot be reassigned 
  integer, dimension(7), intent(in) :: row
  integer, intent(in) :: count

  ! We could initialise these with default values like: `integer :: i = 0`
  ! but, fortran does not deallocate or clear these variables between function invocations
  ! so their values will carry across invocations. To remedy this, we initialise them in 
  ! the function body instead
  integer :: i
  integer :: diff
  integer :: last_diff

  diff = 0
  last_diff = 0

  ! using 0 as safe, >0 as unsafe for a reason
  ! 1 -> diff more than 3 or no diff
  ! 2 -> changed direction ascending
  ! 3 -> change direction descending
  safe = 0

  do i = 2, count, 1
    diff = row(i) - row(i-1)

    ! if there's no difference, unsafe
    if (row(i) == row(i-1)) then
      safe = 1
      exit ! skip to end of loop
    end if

    ! if the difference is > 3, unsafe
    if (diff .gt. 3) then
      safe = 1
      exit ! skip to end of loop
    end if

    ! if the difference is < -3, unsafe
    if (diff .lt. -3) then
      safe = 1
      exit ! skip to end of loop
    end if

    ! start checking for all ascending/descending from the second pair onwards
    if (i >= 3) then
      ! if the current pair is ascending and the previous descending, unsafe
      if (row(i) > row(i-1) .and. row(i-1) < row(i-2)) then
        safe = 2
        exit ! skip to end of loop
      end if

      ! if the current pair is descending and the previous ascending, unsafe
      if (row(i) < row(i-1) .and. row(i-1) > row(i-2)) then
        safe = 3
        exit ! skip to end of loop
      end if
    end if

    last_diff = diff
  end do

end function is_safe

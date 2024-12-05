program hello
  use, intrinsic :: iso_fortran_env, only : iostat_end
  implicit none

  ! declare variables for later use 

  logical :: file_exists
  integer :: file_handle, error
  integer :: i, j, k, safe, safe_count, diff
  character(20) :: filepath
  character(24) :: raw_line
  character(4) :: parse_char
  integer, dimension(:), allocatable :: line
  integer, dimension(7) :: row
  integer, dimension(7) :: line_after_split
  integer :: line_length
  integer :: parsed_num, p_err
  integer :: is_safe

  integer, allocatable :: input(:,:)
  ! allocate(input(x,y))

  read(*,*) filepath

  if (trim(filepath) == trim('example.txt')) then
    print *, "line length 5"
    line_length = 5
    allocate(line(line_length))
  else
    print *, "line length 7"
    line_length = 7
    allocate(line(line_length))
  end if

  safe_count = 0

  inquire(file=filepath, exist=file_exists)
  print *, "file exists", file_exists
  if (file_exists) then
    open(newunit=file_handle, file=trim(filepath), access='sequential', status='old', action='read')

    do
      parse_char = ''
      i = 1
      j = 1
      k = 1
      row = [0,0,0,0,0,0,0]
      read(file_handle, '(A)', iostat = error) raw_line

      raw_line = trim(raw_line)

      select case(error)
      case(0)
        do i = 1, len(raw_line), 1
          ! print *, i, raw_line(i:i), raw_line(i:i) == ' '
          if (raw_line(i:i) == ' ') then
            if (len(parse_char) > 0) then
              read(parse_char, '(i4)') diff
              if (diff > 0) then
                row(k:k) = diff
                k = k + 1
              end if
            end if
            j = 1
            parse_char = ''
          else
            parse_char(j:j) = raw_line(i:i)
            j = j + 1
          end if
        end do
        ! if (line_length == 5) then
        !   row = [line(1), line(2), line(3), line(4), line(5), 0, 0]
        ! else
        !   row = line
        ! end if
        ! print *, raw_line, "|", row
        diff = is_safe(row, k - 1)
        if (diff == 0) then
          safe_count = safe_count + 1
        end if
        print *,  row, '|', k - 1, '|', diff
      case(iostat_end)
        print *, "eof"
        exit
      case default
        print *, "error reading file"
      end select

    !   safe = 0
    !   diff = 0

    !   do i = 2, line_length, 1
    !     if (i >= 3) then
    !       if (row(i) > row(i - 1) .and. row(i-1) < row(i-2)) then
    !         safe = 1
    !         exit
    !       end if
    !       if (row(i) < row(i - 1) .and. row(i-1) > row(i-2)) then
    !         safe = 1
    !         exit
    !       end if
    !     end if

    !     if (row(i) == row(i - 1)) then
    !       safe = 1
    !       exit
    !     end if

    !     diff = row(i) - row(i-1)

    !     if (diff < 0) then
    !       diff = -1 * diff
    !     end if

    !     if (diff > 3) then
    !       safe = 1
    !       exit
    !     end if
    !     if (diff < 1) then
    !       safe = 1
    !       exit
    !     end if
    !   end do

    !   if (safe == 0) then
    !     safe_count = safe_count + 1
    !   end if

    end do

    close(file_handle)
  end if

  print *, "safe count", safe_count

end program hello

function split_line(raw) result (out_row)

  character(24), intent(in) :: raw
  integer, dimension(7) :: out_row
  integer :: i
  integer :: num
  integer :: err

  out_row = [0,0,0,0,0,0,0]
  i = 1
  num = 0

  do
    read(raw, *, iostat=err) num
    out_row(i) = num
    i = i + 1
  end do

end function split_line

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
  integer :: direction
  integer :: last_diff

  diff = 0
  last_diff = 0

  ! using 0 as safe, >0 as unsafe for a reason
  ! 1 -> diff more than 3
  ! 2 -> changed direction ascending
  ! 3 -> change direction descending
  safe = 0

  do i = 2, count, 1
    diff = row(i) - row(i-1)

    if (row(i) == row(i-1)) then
      safe = 1
      exit ! skip to end of loop
    end if

    ! if the difference between two adjacent numbers is > 3,
    ! or there is no difference, exit as unsafe
    if (diff .gt. 3) then
      safe = 1
      exit ! skip to end of loop
    end if

    if (diff .lt. -3) then
      safe = 1
      exit ! skip to end of loop
    end if

    ! ! if the difference between two adjacent numbers is > 3,
    ! ! or there is no difference, exit as unsafe
    ! if (diff .gt. 0 .and. (diff .gt. 3 .or. diff .lt. 1)) then
    !   safe = 1
    !   exit ! skip to end of loop
    ! end if

    ! if (diff .lt. 0 .and. (diff .lt. -3 .or. diff .gt. -1)) then
    !   safe = 1
    !   exit ! skip to end of loop
    ! end if

    ! ! if we've started ascending and the next diff is negative
    ! ! we've changed direction and thus aren't safe
    ! if (last_diff .gt. 0 .and. diff .lt. 0) then
    !   safe = 2
    !   exit ! skip to end of loop
    ! end if

    ! ! if we've started descending and the next diff is positive
    ! ! we've changed direction and thus aren't safe
    ! if (last_diff .lt. 0 .and. diff .gt. 0) then
    !   safe = 3
    !   exit ! skip to end of loop
    ! end if

    ! if we've started ascending and the next diff is negative
    ! we've changed direction and thus aren't safe
    if (i >= 3) then
      if (row(i) > row(i-1) .and. row(i-1) < row(i-2)) then
        safe = 2
        exit ! skip to end of loop
      end if

      ! if we've started descending and the next diff is positive
      ! we've changed direction and thus aren't safe
      if (row(i) < row(i-1) .and. row(i-1) > row(i-2)) then
        safe = 3
        exit ! skip to end of loop
      end if
    end if

    last_diff = diff
  end do

end function is_safe

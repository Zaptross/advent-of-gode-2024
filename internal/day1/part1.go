package day1

import (
	"slices"
	"strconv"
	"strings"
)

func Part1(input string) int {
	left, right := ExtractLists(input)

	slices.Sort(left)
	slices.Sort(right)

	diff := 0
	for i := range len(left) {
		diff += abs(left[i] - right[i])
	}

	return diff
}

func ExtractLists(input string) ([]int, []int) {
	left := []int{}
	right := []int{}
	lines := strings.Split(input, "\n")

	for _, line := range lines {
		parts := strings.Split(line, "   ")

		l, err := strconv.Atoi(parts[0])
		if err != nil {
			continue
		}

		r, err := strconv.Atoi(parts[1])
		if err != nil {
			continue
		}

		left = append(left, l)
		right = append(right, r)
	}

	return left, right
}

func abs(i int) int {
	if i < 0 {
		return -i
	}
	return i
}

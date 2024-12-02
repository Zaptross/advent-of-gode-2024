package day1

func Part2(input string) int {
	left, right := ExtractLists(input)

	counts := countByNumber(right)

	similarity := 0
	for i := range len(left) {
		target := left[i]
		similarity += target * counts[target]
	}

	return similarity
}

func countByNumber(list []int) map[int]int {
	counts := map[int]int{}

	for i := range len(list) {
		target := list[i]
		counts[target] = counts[target] + 1
	}

	return counts
}

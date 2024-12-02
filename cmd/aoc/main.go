package main

import (
	"log/slog"

	"github.com/zaptross/advent-of-gode-2024/internal/day1"
)

func main() {
	printDay(1, 1, day1.Part1(day1.EXAMPLE_INPUT))
	printDay(1, 1, day1.Part1(day1.PUZZLE_INPUT))
	printDay(1, 2, day1.Part2(day1.EXAMPLE_INPUT))
	printDay(1, 2, day1.Part2(day1.PUZZLE_INPUT))
}

func printDay(day, part, result int) {
	slog.Info("",
		"day", day,
		"part", part,
		"result", result)
}

defmodule TestDay3 do
  use ExUnit.Case

  @test_schematic """
  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
  """

  @actual_schematic File.read!("data/day3.txt")

  test "sum of adjacent numbers: schematic 1" do
    assert Day3.sum_of_adjacent_numbers(@test_schematic) == 4361
  end

  test "sum of adjacent numbers: actual schematic" do
    assert Day3.sum_of_adjacent_numbers(@actual_schematic) == 521_515
  end
end
defmodule TestDay9 do
  use ExUnit.Case

  @example_input """
  0 3 6 9 12 15
  1 3 6 10 15 21
  10 13 16 21 30 45
  """

  @actual_input File.read!("data/day9.txt")

  test "test example input" do
    assert Day9.sum_extrapolated(@example_input) == 114
  end

  test "test actual input" do
    assert Day9.sum_extrapolated(@actual_input) == 1681758908
  end

  test "test example input backwards" do
    assert Day9.sum_extrapolated(@example_input, true) == 2
  end

  test "test actual input backwards" do
    assert Day9.sum_extrapolated(@actual_input, true) == 2
  end
end

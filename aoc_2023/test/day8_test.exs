defmodule TestDay8 do
  use ExUnit.Case

  @example_input """
    RL

    AAA = (BBB, CCC)
    BBB = (DDD, EEE)
    CCC = (ZZZ, GGG)
    DDD = (DDD, DDD)
    EEE = (EEE, EEE)
    GGG = (GGG, GGG)
    ZZZ = (ZZZ, ZZZ)
  """

  @example_input2 """
    LLR

    AAA = (BBB, BBB)
    BBB = (AAA, ZZZ)
    ZZZ = (ZZZ, ZZZ)
  """

  @actual_input File.read!("data/day8.txt")

  test "test example input" do
    assert LRMap.num_steps(@example_input) == 2
  end

  test "test example input 2" do
    assert LRMap.num_steps(@example_input2) == 6
  end

  @tag :pending
  test "test actual input" do
    assert LRMap.num_steps(@actual_input, true) == 8
  end
end

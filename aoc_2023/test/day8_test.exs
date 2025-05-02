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

  @example_input_pt2 """
    LR

    11A = (11B, XXX)
    11B = (XXX, 11Z)
    11Z = (11B, XXX)
    22A = (22B, XXX)
    22B = (22C, 22C)
    22C = (22Z, 22Z)
    22Z = (22B, 22B)
    XXX = (XXX, XXX)
  """

  @actual_input File.read!("data/day8.txt")

  test "test example input" do
    assert LRMap.num_steps(@example_input) == 2
  end

  test "test example input 2" do
    assert LRMap.num_steps(@example_input2) == 6
  end

  test "test example input pt. 2" do
    assert LRMap.num_steps(@example_input_pt2, true) == 6
  end

  test "test actual input" do
    assert LRMap.num_steps(@actual_input) == 18673
  end

  test "test actual input pt. 2" do
    assert LRMap.num_steps(@actual_input, true) == 17_972_669_116_327
  end
end

defmodule TestNumerics do
  use ExUnit.Case

  test "test greatest common divisor" do
    assert Numerics.gcd(48, 18) == 6
    assert Numerics.gcd(1, 1) == 1
    assert Numerics.gcd(2, 2) == 2
    assert Numerics.gcd(4, 2) == 2
    assert Numerics.gcd(9, 6) == 3
    assert Numerics.gcd(64, 8) == 8
    assert Numerics.gcd(64, 56) == 8
  end

  test "test least common multiple" do
    assert Numerics.lcm(21, 6) == 42
    assert Numerics.lcm(1, 1) == 1
    assert Numerics.lcm(2, 2) == 2
    assert Numerics.lcm(4, 2) == 4
    assert Numerics.lcm(9, 6) == 18
    assert Numerics.lcm(64, 8) == 64

    assert Numerics.lcm([21, 6]) == 42
    assert Numerics.lcm([21, 6, 42]) == 42
    assert Numerics.lcm([21, 6, 84]) == 84
  end
end

defmodule Day6Test do
  use ExUnit.Case

  @example_races """
  Time:      7  15   30
  Distance:  9  40  200
  """

  @example_races2 """
  Time:      71530
  Distance:  940200
  """

  @actual_races File.read!("data/day6.txt")
  @actual_races2 File.read!("data/day6-2.txt")

  for {time, distance, acc_times} <- [{7, 9, {2, 5}}, {15, 40, {4, 11}}, {30, 200, {11, 19}}] do
    test "test t=#{time} s*=#{distance}" do
      assert Day6.get_acceleration_time_range(unquote(time), unquote(distance)) ==
               unquote(acc_times)
    end
  end

  test "test example races" do
    assert Day6.product_of_winning_options(@example_races) == 4 * 8 * 9
  end

  test "test example races 2" do
    assert Day6.product_of_winning_options(@example_races2) == 71503
  end

  test "test actual races" do
    assert Day6.product_of_winning_options(@actual_races) == 138_915
  end

  test "test actual races pt. 2" do
    assert Day6.product_of_winning_options(@actual_races2) == 27_340_847
  end
end

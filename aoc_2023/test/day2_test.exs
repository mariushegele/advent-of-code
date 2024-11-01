defmodule TestDay2 do
  use ExUnit.Case

  @test_doc1 """
             Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
             Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
             Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
             Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
             Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
             """

  @actual_doc File.read!("data/day2.txt")

  test "sum of possible game ids: doc 1" do
    assert Day2.sum_of_possible_game_ids(@test_doc1) == 8
  end

  test "sum of possible game ids: actual game doc" do
    assert Day2.sum_of_possible_game_ids(@actual_doc) == 1734
  end

  test "sum of game powers: doc 1" do
    assert Day2.sum_of_game_powers(@test_doc1) == 2286
  end

  test "sum of game powers: actual game doc" do
    assert Day2.sum_of_game_powers(@actual_doc) == 70387
  end
end

defmodule TestDay4 do
  use ExUnit.Case

  @test_cards """
    Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
  """

  @test_cards2 """
    Card   1: 1 2 3 | 1 2 3
    Card   2: 1 2 3 | 1 2 3
    Card   3: 1 2 | 1 2
    Card   4: 1 | 1
    Card   5: 1 | 2
  """

  @actual_cards File.read!("data/day4.txt")

  test "sum of points: test cards" do
    assert Day4.sum_of_points(@test_cards) == 13
  end

  test "sum of points: actual cards" do
    assert Day4.sum_of_points(@actual_cards) == 21213
  end

  test "card points: card 1" do
    card =
      "Card 178: 36  1 53 62 73 77 52 59 51  3 | 59 35 68  1 45 77  4 79 83 16 36 63 99 53 52  3 73 51 13 89 84 32 64 33 62"

    # cards are all included => n = 10 => points = 2 ^ 9 == 512
    points = Card.new(card) |> Card.points()
    assert points == 512
  end

  test "num card copies: test cards" do
    assert Day4.num_card_copies(@test_cards) == 30
  end

  test "num card copies: test cards 2" do
    assert Day4.num_card_copies(@test_cards2) ==
             1 + (1 + 1) + (1 + 1 + 2) + (1 + 1 + 2 + 4) + (1 + 0 + 2 + 4 + 8)
  end

  test "num card copies: actual cards" do
    assert Day4.num_card_copies(@actual_cards) == 8_549_735
  end
end

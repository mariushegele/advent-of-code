defmodule TestDay7 do
  use ExUnit.Case

  @example_hands """
    32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483
  """

  @actual_hands File.read!("data/day7.txt")

  test "test example hands" do
    assert CamelHands.winnings(@example_hands, false) == 6440
  end

  test "test example hands pt. 2" do
    assert CamelHands.winnings(@example_hands, true) == 5905
  end

  test "test types (no joker)" do
    assert type("32T3K", false) == "One pair"
    assert type("T55J5", false) == "Three of a kind"
    assert type("QQQJA", false) == "Three of a kind"
    assert type("Q2Q2Q", false) == "Full house"
  end

  test "test types (with joker)" do
    assert type("32T3K", true) == "One pair"
    assert type("T55J5", true) == "Four of a kind"
    assert type("QQQJA", true) == "Four of a kind"
    assert type("Q2Q2Q", true) == "Full house"
  end

  def type(hand, joker) do
    hand |> CamelHand.new() |> CamelHand.type(joker)
  end

  test "test comparator" do
    assert le("32T3K", "T55J5")
    assert not le("T55J5", "32T3K")
    assert le("32T3K", "32T3K")

    # high card higher but 7 < K
    assert le("237QA", "23K64")
  end

  def le(hand1, hand2) do
    value(hand1) <= value(hand2)
  end

  def value(hand) do
    hand |> CamelHand.new() |> CamelHand.value(false)
  end

  test "test actual hands" do
    assert CamelHands.winnings(@actual_hands, false) == 248_113_761
  end

  test "test actual hands, pt. 2" do
    assert CamelHands.winnings(@actual_hands, true) == 246_285_222
  end
end

defmodule CamelHands do
  def new(text_input) do
    InputParser.stream_parsed_lines(text_input, &CamelHandAndBid.new/1)
    |> Enum.to_list()
  end

  def winnings(hands, joker) do
    hands
    |> InputParser.stream_parsed_lines(fn handstr ->
      {handstr, CamelHandAndBid.new(handstr)}
    end)
    |> Enum.map(fn {handstr, {hand, bid}} -> {handstr, CamelHand.value(hand, joker), bid} end)
    |> Enum.sort(fn {_handstr1, values1, _bid1}, {_handstr2, values2, _bid2} ->
      values1 <= values2
    end)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_handstr, _values, bid}, rank} -> bid * rank end)
    |> Enum.sum()
  end
end

defmodule CamelHandAndBid do
  def new(text_input) do
    [hand_input, bid_input] = text_input |> String.trim() |> String.split(" ")
    hand = CamelHand.new(hand_input)
    bid = String.to_integer(bid_input)
    {hand, bid}
  end
end

defmodule CamelHand do
  def new(text_input) do
    text_input |> String.trim() |> String.codepoints() |> Enum.map(&CamelCard.new/1)
  end

  def type(hand, joker) do
    {type, _value} = _type_and_value(hand, joker)
    type
  end

  def value(hand, joker) do
    [hand_value(hand, joker) | card_values(hand, joker)]
    # |> IO.inspect(label: "value of " <> Enum.join(hand, ""))
  end

  defp hand_value(hand, joker) do
    {_type, value} = _type_and_value(hand, joker)
    value
  end

  defp card_values(hand, joker) do
    hand |> Enum.map(fn card -> CamelCard.value(card, joker) end)
  end

  defp _type_and_value(hand, joker) do
    freqs = Enum.frequencies(hand)

    freqs_with_optional_joker_applied =
      if joker do
        apply_joker(freqs)
      else
        freqs
      end

    freqs_with_optional_joker_applied |> Map.values() |> Enum.sort(:desc) |> _type()
  end

  defp apply_joker(freqs) do
    {jokers, freqs_without_j} = Map.pop(freqs, "J", 0)

    case Enum.max_by(freqs_without_j, fn {_k, v} -> v end, fn -> nil end) do
      nil -> freqs
      {letter, max_freq} -> Map.put(freqs_without_j, letter, max_freq + jokers)
    end
  end

  defp _type([5]) do
    {"Five of a kind", 6}
  end

  defp _type([4, 1]) do
    {"Four of a kind", 5}
  end

  defp _type([3, 2]) do
    {"Full house", 4}
  end

  defp _type([3, 1, 1]) do
    {"Three of a kind", 3}
  end

  defp _type([2, 2, 1]) do
    {"Two pair", 2}
  end

  defp _type([2, 1, 1, 1]) do
    {"One pair", 1}
  end

  defp _type([1, 1, 1, 1, 1]) do
    {"High card", 0}
  end
end

defmodule CamelCard do
  def new(text_input) do
    text_input
  end

  def value("A", false), do: 12
  def value("K", false), do: 11
  def value("Q", false), do: 10
  def value("J", false), do: 9
  def value("T", false), do: 8
  def value("9", false), do: 7
  def value("8", false), do: 6
  def value("7", false), do: 5
  def value("6", false), do: 4
  def value("5", false), do: 3
  def value("4", false), do: 2
  def value("3", false), do: 1
  def value("2", false), do: 0

  def value("A", true), do: 12
  def value("K", true), do: 11
  def value("Q", true), do: 10
  def value("T", true), do: 9
  def value("9", true), do: 8
  def value("8", true), do: 7
  def value("7", true), do: 6
  def value("6", true), do: 5
  def value("5", true), do: 4
  def value("4", true), do: 3
  def value("3", true), do: 2
  def value("2", true), do: 1
  def value("J", true), do: 0
end

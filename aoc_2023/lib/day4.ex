defmodule Day4 do
  def sum_of_points(cards) do
    cards
    |> InputParser.stream_parsed_lines(&Card.new/1)
    |> Stream.map(&Card.points/1)
    |> Enum.sum()
  end

  def num_card_copies(cards) do
    num_cards = InputParser.num_lines(cards)

    cards
    |> InputParser.stream_parsed_lines(&Card.new/1)
    |> Enum.reduce(%{}, fn card, card_copies ->
      n = Card.num_winning_numbers(card)
      card_id = Card.card_id(card)

      own_copies = Map.get(card_copies, card_id, 1)
      card_copies = Map.put(card_copies, card_id, own_copies)

      if n == 0 do
        card_copies
      else
        (card_id + 1)..(card_id + n)
        |> Enum.reduce(card_copies, fn fut_card_id, card_copies ->
          update_card_count(fut_card_id, card_copies, own_copies)
        end)
      end
    end)
    |> Enum.filter(fn {card_id, _} -> card_id <= num_cards end)
    |> Enum.reduce(0, fn {_, card_count}, count_sum -> count_sum + card_count end)
  end

  defp update_card_count(card_id, card_copies, to_add) do
    Map.update(card_copies, card_id, 2, fn existing -> existing + to_add end)
  end
end

defmodule Card do
  def new(card_string) do
    card_regex = ~r/^\s*Card\s*(\d+):\s*([^\|]+) \| (.*)$/
    [_, id, winning_numbers, my_numbers] = Regex.run(card_regex, card_string)

    %{
      id: String.to_integer(id),
      winning_numbers: parse_numbers(winning_numbers),
      my_numbers: parse_numbers(my_numbers)
    }
  end

  defp parse_numbers(number_list_string) do
    number_list_string
    |> String.split(" ")
    |> Enum.filter(&InputParser.nonempty/1)
    |> Enum.map(&String.to_integer/1)
    |> MapSet.new()
  end

  def points(card) do
    n = num_winning_numbers(card)

    if n >= 1 do
      Integer.pow(2, n - 1)
    else
      0
    end
  end

  def num_winning_numbers(card) do
    MapSet.intersection(card.winning_numbers, card.my_numbers)
    |> Enum.count()
  end

  def card_id(card) do
    card.id
  end
end

defmodule Day4 do
  def sum_of_points(cards) do
    cards
    |> InputParser.stream_parsed_lines(&Card.new/1)
    |> Stream.map(&Card.points/1)
    |> Enum.sum()
  end

  def num_card_copies(cards) do
    cards
    |> InputParser.stream_parsed_lines(&Card.new/1)
    |> CardSet.new()
    |> CardSet.sum_card_copies()
  end
end

defmodule CardSet do
  def new(card_enum) do
    Map.new(card_enum, fn card -> {Card.id(card), card} end)
  end

  def get(card_set, id) do
    card_set.get!(id)
  end

  def size(card_set) do
    Enum.count(card_set)
  end

  def sum_card_copies(card_set) do
    1..size(card_set)
    |> Enum.reduce(card_set, fn card_id, updated_card_set ->
      update_copies(updated_card_set, card_id)
    end)
    |> Enum.filter(fn {card_id, _} -> card_id <= size(card_set) end)
    |> Enum.reduce(0, fn {_, card}, sum -> sum + Card.copies(card) end)
  end

  defp update_copies(card_set, card_id) do
    card = card_set[card_id]
    n = Card.num_winning_numbers(card)

    if n == 0 do
      card_set
    else
      (Card.id(card) + 1)..(Card.id(card) + n)
      |> Enum.reduce(card_set, fn fut_card_id, new_card_set ->
        Map.update!(new_card_set, fut_card_id, fn existing ->
          Card.add_copies(existing, Card.copies(card))
        end)
      end)
    end
  end
end

defmodule Card do
  def new(card_string) do
    card_regex = ~r/^\s*Card\s*(\d+):\s*([^\|]+) \| (.*)$/
    [_, id, winning_numbers, my_numbers] = Regex.run(card_regex, card_string)
    winning_numbers = parse_numbers(winning_numbers)
    my_numbers = parse_numbers(my_numbers)

    %{
      id: String.to_integer(id),
      num_winning_numbers: Enum.count(MapSet.intersection(winning_numbers, my_numbers)),
      copies: 1
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
    card.num_winning_numbers
  end

  def id(card) do
    card.id
  end

  def copies(card) do
    card.copies
  end

  def add_copies(card, num_copies) do
    Map.update!(card, :copies, fn current_copies ->
      current_copies + num_copies
    end)
  end
end

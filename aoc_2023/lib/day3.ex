defmodule Day3 do
  @doc """
    Point {x, y}

    discover symbols -> collect points
    number is adjacent to a symbol if and only if 
      

    grid examle
      0123456789
    0 467..114..
    1 ...*7.....
    2 ..35..633.

    points here displayed in (y, x)
    -> symbol at (1,3) -> adjacent fields: (0-2,2-4)
    -> numbers at
      * 467: (0,0) to (0,2) diagaonally adjacent: intersects (0,2)
      * 114: (0,5) to (0,7) not adjacent
      * 7:   (1,4) to (1,4) right adjacent: intersects (1,4)
      * 35:  (2,3) to (2,4) lower adjacent: intersects (2,3) to (2,4)
      * 633: (2,6) to (2,8) not adjacent

    strategy:
      1. convert symbols to a set of points (one-dimensional is sufficient)
      2. convert numbers to a collection of sets of points indicating their point
      3. for each number: check if any of its points are in set 1.

  """

  @spec sum_of_adjacent_numbers(String.t()) :: number
  def sum_of_adjacent_numbers(schematic) do
    symbol_adjacent_point_set = point_set_adjacent_to_any_symbol(schematic, ~r/[^\d\.]/)
    number_points = get_number_points(schematic)

    get_intersecting_numbers(number_points, symbol_adjacent_point_set)
    |> Enum.sum()
  end

  @spec sum_of_gear_ratios(String.t()) :: number
  def sum_of_gear_ratios(schematic) do
    stars =
      symbol_adjacent_points(schematic, ~r/\*/)
      |> Enum.map(&MapSet.new/1)

    number_points = get_number_points(schematic) |> MapSet.new()

    stars
    |> Enum.map(fn star_adjacent_points ->
      symbol_intersecting_numbers(star_adjacent_points, number_points)
    end)
    |> Enum.filter(fn number_points -> length(number_points) > 1 end)
    |> Enum.map(&gear_ratio/1)
    |> Enum.sum()
  end

  def symbol_intersecting_numbers(symbol_points, number_points) do
    Enum.filter(number_points, fn number_point ->
      number_in_point_set?(number_point, symbol_points)
    end)
  end

  defp gear_ratio(number_points) do
    number_points
    |> Enum.map(fn {_, {number, _}} -> number end)
    |> Enum.product()
  end

  defp point_set_adjacent_to_any_symbol(schematic, symbol_regex) do
    symbol_adjacent_points(schematic, symbol_regex)
    |> List.flatten()
    |> MapSet.new()
  end

  def symbol_adjacent_points(schematic, symbol_regex) do
    schematic
    |> String.split("\n")
    |> Enum.map(fn line -> parse_symbol_points(line, symbol_regex) end)
    |> Enum.with_index()
    |> Enum.map(&expand_row_to_coordinates/1)
    |> List.flatten()
    |> Enum.map(&get_adjacent_points/1)
  end

  defp expand_row_to_coordinates({xs, y}) do
    Enum.map(xs, fn x -> {y, x} end)
  end

  defp get_adjacent_points({y, x}) do
    [
      {max(0, y - 1), max(0, x - 1)},
      {max(0, y - 1), x},
      {max(0, y - 1), x + 1},
      {y, max(0, x - 1)},
      {y, x},
      {y, x + 1},
      {y + 1, max(0, x - 1)},
      {y + 1, x},
      {y + 1, x + 1}
    ]
  end

  defp get_number_points(schematic) do
    schematic
    |> String.split("\n")
    |> Enum.map(&parse_number_points/1)
    |> Enum.with_index()
    |> Enum.map(&expand_row_to_coordinates/1)
    |> List.flatten()
  end

  defp parse_number_points(schematic_line) do
    # returns list of tuples {number, {y,x_start, y,x_end}}
    Regex.scan(~r/\d+/, schematic_line, return: :index)
    |> List.flatten()
    |> Enum.map(fn {x_start, match_length} ->
      {
        String.slice(schematic_line, x_start, match_length) |> String.to_integer(),
        {x_start, x_start + match_length - 1}
      }
    end)
  end

  defp parse_symbol_points(schematic_line, symbol_regex) do
    Regex.scan(symbol_regex, schematic_line, return: :index)
    |> List.flatten()
    |> Enum.map(fn {x_start, match_length} -> x_start end)
  end

  defp get_intersecting_numbers(number_points, symbol_adjacent_point_set) do
    number_points
    |> Enum.filter(fn number -> number_in_point_set?(number, symbol_adjacent_point_set) end)
    |> Enum.map(fn {_, {number, _}} -> number end)
  end

  defp number_in_point_set?({y, {number, {x_start, x_end}}}, point_set) do
    x_start..x_end
    |> Enum.any?(fn x -> MapSet.member?(point_set, {y, x}) end)
  end
end

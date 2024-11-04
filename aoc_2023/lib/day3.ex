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
      2. convert numbers to a collection of sets of points indicating their location
      3. for each number: check if any of its points are in set 1.

  """

  @spec sum_of_adjacent_numbers(String.t()) :: number
  def sum_of_adjacent_numbers(schematic) do
    symbol_adjacent_point_set = get_symbol_adjacent_point_set(schematic)
    number_locations = get_number_locations(schematic)

    get_intersecting_numbers(number_locations, symbol_adjacent_point_set)
    |> Enum.sum()
  end

  def get_symbol_adjacent_point_set(schematic) do
    schematic
    |> String.split("\n")
    |> Enum.map(&parse_symbol_locations/1)
    |> Enum.with_index()
    |> Enum.map(&expand_row_to_coordinates/1)
    |> List.flatten()
    |> Enum.map(&get_adjacent_points/1)
    |> List.flatten()
    |> MapSet.new()
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

  defp get_number_locations(schematic) do
    schematic
    |> String.split("\n")
    |> Enum.map(&parse_number_locations/1)
    |> Enum.with_index()
    |> Enum.map(&expand_row_to_coordinates/1)
    |> List.flatten()
  end

  defp parse_number_locations(schematic_line) do
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

  defp parse_symbol_locations(schematic_line) do
    Regex.scan(~r/[^\d\.]/, schematic_line, return: :index)
    |> List.flatten()
    |> Enum.map(fn {x_start, match_length} -> x_start end)
  end

  defp get_intersecting_numbers(number_locations, symbol_adjacent_point_set) do
    number_locations
    |> Enum.filter(fn number -> number_intersects?(number, symbol_adjacent_point_set) end)
    |> Enum.map(fn {_, {number, _}} -> number end)
  end

  defp number_intersects?({y, {number, {x_start, x_end}}}, symbol_adjacent_point_set) do
    x_start..x_end
    |> Enum.any?(fn x -> MapSet.member?(symbol_adjacent_point_set, {y, x}) end)
  end
end

defmodule Day2 do
  @max_cube_counts %{red: 12, green: 13, blue: 14}

  @spec sum_of_possible_game_ids(String.t()) :: number
  def sum_of_possible_game_ids(game_doc) do
    game_doc
    |> read_games()
    |> Enum.map(&id_of_game_if_possible/1)
    |> Enum.sum()
  end

  @spec sum_of_game_powers(String.t()) :: number
  def sum_of_game_powers(game_doc) do
    game_doc
    |> read_games()
    |> Enum.map(&power_of_game/1)
    |> Enum.sum()
  end

  @spec read_games(String.t()) :: List
  defp read_games(game_doc) do
    game_doc
    |> String.trim()
    |> String.split("\n")
  end

  @spec id_of_game_if_possible(String.t()) :: number
  defp id_of_game_if_possible(game_desc) do
    {game_id, max_draw_counts} = get_game_id_and_max_draw_counts(game_desc)
    max_with_cap = merge_maps_by_maximum_value(max_draw_counts, @max_cube_counts)

    if max_with_cap == @max_cube_counts do
      game_id
    else
      0
    end
  end

  @spec power_of_game(String.t()) :: number
  defp power_of_game(game_desc) do
    {_, max_draw_counts} = get_game_id_and_max_draw_counts(game_desc)

    Map.values(max_draw_counts)
    |> Enum.product()
  end

  @spec get_game_id_and_max_draw_counts(String.t()) :: {number, map}
  defp get_game_id_and_max_draw_counts(game_desc) do
    {game_id, draws} = read_game_id_and_draws(game_desc)
    {game_id, game_max_draw_counts(draws)}
  end

  @spec read_game_id_and_draws(String.t()) :: {number, String.t()}
  defp read_game_id_and_draws(game_desc) do
    [_, game_id, draws] = Regex.run(~r/^Game (\d+): (.*)$/, game_desc)
    {String.to_integer(game_id), draws}
  end

  @spec game_max_draw_counts(String.t()) :: map
  defp game_max_draw_counts(draws) do
    draws
    |> String.split(";")
    |> Enum.map(&read_draw_cube_counts/1)
    |> Enum.reduce(%{}, &merge_maps_by_maximum_value/2)
  end

  @spec merge_maps_by_maximum_value(map, map) :: map
  defp merge_maps_by_maximum_value(map1, map2) do
    Map.merge(map1, map2, fn _key, v1, v2 -> max(v1, v2) end)
  end

  @spec read_draw_cube_counts(String.t()) :: map
  defp read_draw_cube_counts(draw_desc) do
    # example: 3 green, 4 blue, 1 red -> {green: 3, blue: 4, red: 1}
    String.split(draw_desc, ",")
    |> Enum.map(&read_single_cube_count/1)
    |> Map.new()
  end

  @spec read_single_cube_count(String.t()) :: {number, number}
  defp read_single_cube_count(cube_count_desc) do
    # example: " 3 green" -> {:green, 3}
    [_, count, color] = Regex.run(~r/^[^\d]*(\d+) ([^\s]+)/, cube_count_desc)
    {String.to_existing_atom(color), String.to_integer(count)}
  end
end

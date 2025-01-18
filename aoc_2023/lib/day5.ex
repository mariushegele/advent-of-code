defmodule Day5 do
  def closest_location(input) do
    {seeds_input, maps_input} = split_input(input)
    seeds = Seeds.from_list(seeds_input)
    maps = SequentialRangeMaps.new(maps_input)

    locations(seeds, maps)
    |> Enum.min()
  end

  defp locations(seeds, maps) do
    seeds
    |> Enum.map(fn seed -> SequentialRangeMaps.get(maps, seed) end)
  end

  def closest_location_of_seed_ranges(input) do
    {seeds_input, maps_input} = split_input(input)
    seed_ranges = Seeds.parse_ranges(seeds_input)
    maps = SequentialRangeMaps.new(maps_input)
    fdm = FinalDestinationMap.new(maps)

    FinalDestinationMap.closest_location_of_seed_ranges(fdm, seed_ranges)
  end

  defp split_input(seeds_and_maps) do
    [seeds_input | maps_lines] =
      seeds_and_maps
      |> String.trim()
      |> String.split("\n")

    maps_input = Enum.join(maps_lines, "\n")

    {seeds_input, maps_input}
  end
end

defmodule Seeds do
  def from_list(seeds_line) do
    seeds_line
    |> parse_numbers()
  end

  def parse_ranges(seeds_line) do
    numbers = parse_numbers(seeds_line)
    num_pairs = div(Enum.count(numbers), 2)

    0..(num_pairs - 1)
    |> Enum.map(fn i -> {Enum.at(numbers, 2 * i + 0), Enum.at(numbers, 2 * i + 1)} end)
  end

  defp parse_numbers(seeds_line) do
    [_, numbers] = Regex.run(~r/seeds:\s+(.+)/, seeds_line)

    numbers
    |> String.trim()
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule SequentialRangeMaps do
  def new(text_input) do
    text_input
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(&RangeMap.new/1)
  end

  def get(maps, key) do
    maps |> Enum.reduce(key, &RangeMap.get/2)
  end
end

defmodule FinalDestinationMap do
  def new(sequential_range_maps) do
    reversed = Enum.reverse(sequential_range_maps)

    [last | _rest_reversed] = reversed
    final_destination_map = [{0, RangeMap.max_dest_value(last)}]

    {ranges, _acc} =
      reversed
      |> Enum.reduce(final_destination_map, fn map, final_destination_map ->
        RangeMap.break_into(map, final_destination_map)
      end)
      |> Enum.map_reduce(0, fn {start, stop}, index ->
        {{index, {start, stop}}, index + stop - start + 1}
      end)

    ranges
  end

  def closest_location_of_seed_ranges(fdm, seed_ranges) do
    seed_ranges
    |> Enum.map(fn seed_range -> closest_location_of_seed_range(fdm, seed_range) end)
    |> Enum.min()
  end

  def closest_location_of_seed_range(fdm, {seed_start, delta}) do
    last = Enum.at(fdm, -1)

    seed_stop = seed_start + delta

    {index, {start, _stop}} =
      fdm
      |> Enum.find(last, fn {_index, {start, stop}} ->
        PlainRange.ranges_intersect({start, stop}, {seed_start, seed_stop})
      end)

    index + max(seed_start, start) - start
  end

  def get(fdm, key) do
    last = Enum.at(fdm, -1)

    {index, {start, _stop}} =
      fdm
      |> Enum.find(last, fn {_index, {start, stop}} -> start <= key and key <= stop end)

    index + (key - start)
  end
end

defmodule RangeMap do
  def new(map_label_and_ranges) do
    [_label | ranges] =
      map_label_and_ranges
      |> String.trim()
      |> String.split("\n")

    ranges
    |> Stream.map(&MappedRange.new/1)
    |> Enum.sort(fn range1, range2 ->
      MappedRange.start_source(range1) <= MappedRange.start_source(range2)
    end)
  end

  def get(map, key) do
    range = Enum.find(map, fn range -> MappedRange.in_source_range(range, key) end)

    case range do
      nil -> key
      range -> MappedRange.map(range, key)
    end
  end

  def sort_by_destination(map) do
    map
    |> Enum.sort(fn range1, range2 ->
      MappedRange.start_dest(range1) <= MappedRange.start_dest(range2)
    end)
  end

  def max_dest_value(map) do
    map |> Stream.map(&MappedRange.max_dest_value/1) |> Enum.max()
  end

  def break_into(map, final_destination_map) do
    # {15, 51}, {52, 53}, {0, 14}
    # dest_ranges {50, 51}, {52, 99}
    # src_ranges  {98, 99}, {50, 97}

    # goal: {15, 49}, {98, 99}, {50, 51}, {0, 14}, ( {52, 97} )

    # go over final_destination_map
    # {15, 51} -> find relevant ranges: {50, 51} subset   => break up: {15, 49}, {50, 51} and replace: {15, 49}, {98, 99}
    # {52, 53} -> find relevant ranges: {52, 99} superset => keep {52, 53} and replace: {50, 51}
    # { 0, 14} -> find relevant ranges: none => keep {0, 14}

    # left over: dest {54, 99} = {52, 97} (not needed?)

    dest_sorted_map = sort_by_destination(map)

    final_destination_map
    |> Enum.map(fn final_dest_range ->
      {leftover_final_dest_range, source_ranges} =
        Enum.filter(dest_sorted_map, fn range ->
          MappedRange.intersects_destination(range, final_dest_range)
        end)
        |> Enum.reduce({final_dest_range, []}, fn range,
                                                  {leftover_final_dest_range, all_source_ranges} ->
          {leftover_final_dest_range, source_ranges} =
            MappedRange.split_up_into_source(range, leftover_final_dest_range)

          {leftover_final_dest_range, all_source_ranges ++ source_ranges}
        end)

      if leftover_final_dest_range != nil do
        List.insert_at(source_ranges, -1, leftover_final_dest_range)
      else
        source_ranges
      end
    end)
    |> List.flatten()

    # {0, 36} -> find in {0, 53} -> index = 0 -> add [  ]
    # {0, 36}, {37, 38}, {39, 53}
  end
end

defmodule MappedRange do
  def new(text) do
    # e.g. 0 15 37
    format = ~r/(\d+)\s+(\d+)\s+(\d+)/
    [_, range_start_dest, range_start_source, len] = Regex.run(format, text)

    %{
      start_source: String.to_integer(range_start_source),
      start_dest: String.to_integer(range_start_dest),
      length: String.to_integer(len)
    }
  end

  def in_source_range(range, number) do
    range.start_source <= number and number < range.start_source + range.length
  end

  def intersects_destination(range, {dest_range_start, dest_range_end}) do
    {a, b} = dest_range(range)
    {c, d} = {dest_range_start, dest_range_end}
    PlainRange.ranges_intersect({a, b}, {c, d})
  end

  def source_range_of_dest_intersection(range, {dest_range_start, dest_range_end}) do
    {a, b} = dest_range(range)
    {c, d} = {dest_range_start, dest_range_end}

    {intersection_start, intersection_end} = {max(a, c), min(b, d)}
    {invert_map(range, intersection_start), invert_map(range, intersection_end)}
  end

  def split_up_into_source(range, {dest_range_start, dest_range_end}) do
    {a, b} = dest_range(range)
    {c, d} = {dest_range_start, dest_range_end}

    # scenario 1: [a    b][e  ?  f]      -> range: [c b] leftover: [b d]
    #                 [c    d]
    #
    # scenario 2: [a       b] -> [c d]  -> range: [c  d] leftover: none
    #               [c  d]
    #
    # scenario 3:      [a    b] -> ranges: [c, a - 1] (Id.) + [a  d] leftover: none
    #             [c    d]
    #
    # scenario 4:    [a  b]     ->  ranges: [c,  a - 1] (Id.) + [a  b] leftover: [b + 1, d]
    #             [c       d]

    {intersection_start, intersection_end} = {max(a, c), min(b, d)}
    source_range = {invert_map(range, intersection_start), invert_map(range, intersection_end)}

    source_ranges =
      if c < a do
        [{c, a - 1}, source_range]
      else
        [source_range]
      end

    leftover =
      if b < d do
        {b + 1, d}
      else
        nil
      end

    {leftover, source_ranges}
  end

  def start_source(range) do
    range.start_source
  end

  def start_dest(range) do
    range.start_dest
  end

  def dest_range(range) do
    {range.start_dest, range.start_dest + range.length - 1}
  end

  def map(range, key) do
    key - range.start_source + range.start_dest
  end

  def invert_map(range, key) do
    key - range.start_dest + range.start_source
  end

  def max_dest_value(range) do
    range.start_dest + range.length
  end
end

defmodule PlainRange do
  def ranges_intersect({a, b}, {c, d}) do
    # (a, b) & (c, d)
    # negative:
    # [a  b]
    #        [c d]
    #             [a b]
    not (b < c or a > d)
  end
end

defmodule Day5 do
  def closest_location(input) do
    {seeds_input, maps_input} = split_input(input)
    seeds = Seeds.from_list(seeds_input)
    maps = SequentialRangeMaps.new(maps_input)
    locations(seeds, maps)
    |> Enum.min()
  end
  def closest_location_of_seed_ranges(input) do
    {seeds_input, maps_input} = split_input(input)
    seeds = Seeds.from_ranges(seeds_input)
    maps = SequentialRangeMaps.new(maps_input)
    locations(seeds, maps)
    |> Enum.min()
  end

  defp locations(seeds, maps) do
    seeds
    |> Enum.map(fn seed -> SequentialRangeMaps.get(maps, seed) end)
  end

  defp split_input(seeds_and_maps) do
    [seeds_input | maps_lines] = seeds_and_maps
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


  def from_ranges(seeds_line) do
    numbers = parse_numbers(seeds_line)
    num_pairs = div(Enum.count(numbers), 2)
    0..(num_pairs - 1)
    |> Enum.map(fn i -> {Enum.at(numbers, 2 * i + 0), Enum.at(numbers, 2 * i + 1)} end)
    |> IO.inspect()
    |> Enum.reduce([], fn {first_seed, seed_count}, seeds -> 
      Enum.to_list(first_seed..(first_seed + seed_count - 1)) ++ seeds end)
      |> IO.inspect()
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

defmodule RangeMap do
  def new(map_label_and_ranges) do
    [_label | ranges] = map_label_and_ranges 
    |> String.trim()
    |> String.split("\n")

    ranges
    |> Stream.map(&MappedRange.new/1)
    |> Enum.sort(fn range1, range2 -> 
      MappedRange.start_source(range1) <= MappedRange.start_source(range2) end)
  end

  def get(map, key) do
    range = Enum.find(map, fn range -> MappedRange.in_source_range(range, key) end)
    case range do
      nil -> key
      range -> MappedRange.map(range, key)
    end

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

  def start_source(range) do
    range.start_source
  end

  def map(range, key) do
    key - range.start_source + range.start_dest
  end
end

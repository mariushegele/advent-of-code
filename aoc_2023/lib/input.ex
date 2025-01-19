defmodule InputParser do
  def stream_parsed_lines(input, parse_fn) do
    input
    |> stream_nonempty_lines()
    |> Stream.map(parse_fn)
  end

  def stream_nonempty_lines(input) do
    input
    |> String.split("\n")
    |> Stream.filter(&nonempty/1)
  end

  def num_lines(input) do
    input
    |> stream_nonempty_lines()
    |> Enum.count()
  end

  def nonempty(string) do
    String.trim(string) != ""
  end

  def nth_nonempty_line(input, n) do
    stream_nonempty_lines(input)
    |> Enum.at(n)
  end

  def remove_header_and_parse_integer_list(line, header) do
    [_, rest] = String.split(line, header)

    rest
    |> String.trim()
    |> String.split(~r/\s+/)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
  end
end

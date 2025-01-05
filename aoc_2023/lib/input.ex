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
end

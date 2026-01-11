defmodule Day9 do
  def sum_extrapolated(input, backwards \\ false) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> extrapolate_line(line, backwards) end)
    |> Enum.sum()
  end

  defp extrapolate_line(line, backwards) do
    line
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> recur_extrapolate(backwards)
  end

  defp recur_extrapolate(numbers, backwards) do
    if Enum.all?(numbers, fn n -> n == 0 end) do
      0
    else
      diffs = pairwise_differences(numbers)
      extrapolated_n = recur_extrapolate(diffs, backwards)
      if backwards do
        first_n = Enum.at(numbers, 0)
        first_n - extrapolated_n
      else
        last_n = Enum.at(numbers, -1)
        last_n + extrapolated_n
      end
    end
  end

  defp pairwise_differences(numbers) do
    numbers
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [l, r] -> r - l end)
  end
end

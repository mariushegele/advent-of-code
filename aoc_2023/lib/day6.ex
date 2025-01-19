defmodule Day6 do
  def product_of_winning_options(input_text) do
    # example: 
    # Time:      7  15   30
    # Distance:  9  40  200

    times_line = InputParser.nth_nonempty_line(input_text, 0)
    distances_line = InputParser.nth_nonempty_line(input_text, 1)

    times = InputParser.remove_header_and_parse_integer_list(times_line, "Time:")
    distances = InputParser.remove_header_and_parse_integer_list(distances_line, "Distance:")

    Stream.zip([times, distances])
    |> Stream.map(fn {time, distance} -> get_acceleration_time_range(time, distance) end)
    |> Stream.map(&range_to_num_winning_options/1)
    |> Enum.product()
  end

  def get_acceleration_time_range(time, distance) do
    sqrt_body = :math.pow(time, 2) - 4 * distance

    if sqrt_body >= 0 do
      x = :math.sqrt(sqrt_body)
      t1 = (time - x) / 2
      t2 = (time + x) / 2
      {smallest_integer_larger_than(t1), largest_integer_smaller_than(t2)}
    else
      nil
    end
  end

  defp range_to_num_winning_options(nil), do: 0
  defp range_to_num_winning_options({start, stop}), do: stop - start + 1

  defp smallest_integer_larger_than(x) do
    ceiled = :math.ceil(x)

    if ceiled > x do
      ceiled
    else
      ceiled + 1
    end
    |> trunc()
  end

  defp largest_integer_smaller_than(x) do
    floored = :math.floor(x)

    if floored < x do
      floored
    else
      floored - 1
    end
    |> trunc()
  end
end

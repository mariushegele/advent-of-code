defmodule Day1 do
  @spec sum_of_calibration_values(String.t()) :: number
  def sum_of_calibration_values(calibration_doc, opts \\ []) do
    with_alpha_num = Keyword.get(opts, :with_alpha_num, false)

    calibration_doc
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> get_calibration_number(line, with_alpha_num) end)
    |> Enum.sum()
  end

  @spec get_calibration_number(String.t(), boolean) :: number
  defp get_calibration_number(calibration_line, with_alpha_num) do
    regex =
      case with_alpha_num do
        true -> ~r/(?=(?<num>\d|one|two|three|four|five|six|seven|eight|nine))/
        false -> ~r/(?<num>\d)/
      end

    digits = Regex.scan(regex, calibration_line, capture: :all_names) |> List.flatten()

    {first_digit, last_digit} =
      case digits do
        # [] -> # TODO erroneous calibration line
        [single] -> {single, single}
        _ -> {List.first(digits), List.last(digits)}
      end

    string_rep_to_num(first_digit, last_digit)
  end

  defp string_rep_to_num(first_digit, last_digit) do
    (optional_alpha_int_to_int(first_digit) <> optional_alpha_int_to_int(last_digit))
    |> String.to_integer()
  end

  defp optional_alpha_int_to_int(alpha_numeric_digit) do
    alpha_num_to_num = %{
      "one" => "1",
      "two" => "2",
      "three" => "3",
      "five" => "5",
      "four" => "4",
      "six" => "6",
      "eight" => "8",
      "seven" => "7",
      "nine" => "9"
    }

    Regex.replace(~r/[a-z]+/, alpha_numeric_digit, fn match ->
      alpha_num_to_num[match]
    end)
  end
end

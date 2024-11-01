defmodule Day1 do

  @spec sum_of_calibration_values(String.t()) :: number
  def sum_of_calibration_values(calibration_doc) do
    calibration_doc
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&get_calibration_number/1)
    |> Enum.sum()
  end

  @spec get_calibration_number(String.t()) :: number
  defp get_calibration_number(calibration_line) do
    digits = Regex.scan(~r/\d/, calibration_line) |> List.flatten()
    {first_digit, last_digit} = case digits do
      # [] -> # TODO erroneous calibration line
      [single] -> {single, single}
      _ -> {List.first(digits), List.last(digits)}
    end
    String.to_integer(first_digit <> last_digit)
  end

end

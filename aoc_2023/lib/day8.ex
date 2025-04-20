defmodule LRMap do
  def num_steps(input) do
    {instructions_input, map_input} = InputParser.split_into_header_and_rest(input)
    instructions = parse_instructions(instructions_input)
    map = parse_map(map_input)

    search_zzz(map, instructions, "AAA", 0)
  end

  defp search_zzz(map, instructions, active_node, i) do
    if active_node == "ZZZ" do
      i
    else
      j = rem(i, Enum.count(instructions))
      instruction = Enum.at(instructions, j)
      {left_node, right_node} = Map.get(map, active_node)

      new_active_node =
        case instruction do
          "L" -> left_node
          "R" -> right_node
        end

      search_zzz(map, instructions, new_active_node, i + 1)
    end
  end

  defp parse_instructions(input) do
    input
    |> String.trim()
    |> String.graphemes()
  end

  defp parse_map(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Enum.map(&parse_map_line/1)
    |> Map.new()
  end

  def parse_map_line(line) do
    [_line, loc, left, right] = Regex.run(~r/([A-Z]+)\s=\s\(([A-Z]+),\s([A-Z]+)\)/, line)
    {loc, {left, right}}
  end
end

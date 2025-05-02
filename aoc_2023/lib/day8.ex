defmodule LRMap do
  def num_steps(input, simultaneous \\ false) do
    {instructions_input, map_input} = InputParser.split_into_header_and_rest(input)
    instructions = parse_instructions(instructions_input)
    map = parse_map(map_input)

    {initial_nodes, finish_suffix} =
      if simultaneous do
        {nodes_ending_with(map, "A"), "Z"}
      else
        {["AAA"], "ZZZ"}
      end

    initial_nodes
    |> Enum.map(fn node ->
      search_finish_nodes(map, instructions, node, finish_suffix, 0)
    end)
    |> Numerics.lcm()
  end

  defp search_finish_nodes(map, instructions, active_node, finish_suffix, num_steps) do
    if String.ends_with?(active_node, finish_suffix) do
      num_steps
    else
      i = rem(num_steps, Enum.count(instructions))
      instruction = Enum.at(instructions, i)

      new_active_node = step_node(map, active_node, instruction)
      search_finish_nodes(map, instructions, new_active_node, finish_suffix, num_steps + 1)
    end
  end

  defp step_node(map, active_node, instruction) do
    {left_node, right_node} = Map.get(map, active_node)

    case instruction do
      "L" -> left_node
      "R" -> right_node
    end
  end

  defp nodes_ending_with(map, suffix) do
    Map.keys(map)
    |> Enum.filter(fn key -> String.ends_with?(key, suffix) end)
    |> MapSet.new()
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
    line_regex = ~r/([A-Z0-9]+)\s=\s\(([A-Z0-9]+),\s([A-Z0-9]+)\)/
    [_line, loc, left, right] = Regex.run(line_regex, line)
    {loc, {left, right}}
  end
end

defmodule Numerics do
  def gcd(d, 0) do
    d
  end

  def gcd(a, b) when a >= b do
    gcd(b, rem(a, b))
  end

  def gcd(a, b) when b > a do
    gcd(a, rem(b, a))
  end

  def lcm(a, b) do
    abs(a) * div(abs(b), gcd(a, b))
  end

  def lcm([head | tail]) do
    Enum.reduce(tail, head, &lcm(&1, &2))
  end
end

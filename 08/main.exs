defmodule App do
  def process_file do
    {:ok, text} = File.read("./input.txt")
    [directions_line | rest] = String.split(text, "\n", trim: true)
    directions = parse_directions(directions_line)
    nav_map = NavigationMap.parse(rest)
    NavigationMap.navigate_multiple(nav_map, directions)
  end

  def parse_directions(line) do
    String.trim(line)
    |> String.graphemes()
  end
end

defmodule NavigationMap do
  defstruct [:connections]

  def parse(lines) do
    connections = Enum.map(lines, &(ConnectionNode.parse(&1)))

    %NavigationMap{
      connections: Map.new(connections, fn connection -> {connection.from, connection} end)
    }
  end

  def navigate(%NavigationMap{connections: connections} = nav_map, instructions) do
    start_node = Map.get(connections, "AAA")
    steps = Stream.cycle(instructions)
    |> Stream.scan(start_node, &(NavigationMap.navigate_step(nav_map, &2, &1)))
    |> Stream.take_while(fn node -> node.from != "ZZZ" end)
    |> Enum.to_list()

    num_steps = steps |> Enum.count()

    num_steps + 1

    # |> Stream.scan(Map.get(connections, "AAA"), &(NavigationMap.navigate_step(nav_map, &2, &1)))
    # |> Stream.take_while(fn node -> node.from != "ZZZ" end)
    # |> Enum.to_list()
  end

  def navigate_multiple(%NavigationMap{connections: connections} = nav_map, instructions) do
    starting_nodes = Map.values(connections) |> Enum.filter(fn val -> String.ends_with?(val.from, "A") end)
    counts = for start_node <- starting_nodes do
      Stream.cycle(instructions)
      |> Stream.scan(start_node, &(NavigationMap.navigate_step(nav_map, &2, &1)))
      |> Stream.take_while(fn node -> !String.ends_with?(node.from,"Z") end)
      |> Enum.count()
      |> Kernel.+(1)
    end

    Enum.reduce(counts, &(round(BasicMath.lcm(&1, &2))))
  end

  def print_first_if_z(nodes) do
    node = Enum.at(nodes, 5)
    if String.ends_with?(node.from, "Z") do IO.inspect(node) end
  end

  def navigate_step(%NavigationMap{connections: connections}, current_node, current_instruction) do
    case current_instruction do
      "L" -> Map.get(connections, current_node.to_left, :nil)
      "R" -> Map.get(connections, current_node.to_right, :nil)
    end
  end
end

defmodule BasicMath do
	def gcd(a, 0), do: a
	def gcd(0, b), do: b
	def gcd(a, b), do: gcd(b, rem(a,b))

	def lcm(0, 0), do: 0
	def lcm(a, b), do: (a*b)/gcd(a,b)
end

defmodule ConnectionNode do
  defstruct [:from, :to_left, :to_right]

  def parse(line) do
    [_, node_from, node_to_left, node_to_right] = Regex.run(~r/(.+) = \((.+)\, (.+)\)/, line)
    %ConnectionNode{
      from: node_from,
      to_left: node_to_left,
      to_right: node_to_right
    }
  end
end


IO.inspect(App.process_file(), charlists: :as_lists)

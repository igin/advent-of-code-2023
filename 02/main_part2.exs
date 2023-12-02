defmodule App do
  def process_file do
    {:ok, text} = File.read("./input.txt")
    lines = String.split(text, "\n")
    process_lines(lines)
  end

  def process_lines(lines, acc \\ 0)
  def process_lines([], acc), do: acc
  def process_lines([line | rest], acc) do
    game = parse_line(line)
    cube_set = minimum_cube_set_game(game)
    power = Map.get(cube_set, "red", 0) * Map.get(cube_set, "green", 0) * Map.get(cube_set, "blue", 0)

    process_lines(rest, acc + power)
  end

  def parse_line(string) do
    game_id = Regex.run(~r/Game (\d*):/, string) |> Enum.at(1) |> Integer.parse() |> elem(0)
    rounds_strings = Regex.run(~r/:(.*)/, string) |> Enum.at(1) |>  String.split(";", trim: true)
    rounds = for round <- rounds_strings do
      for draw <- String.split(round, ",", trim: true) do
        [number, color] = String.split(draw, " ", trim: true)
        %{color => Integer.parse(number) |> elem(0)}
      end
    end
    %{game_id: game_id, rounds: rounds}
  end

  def minimum_cube_set_game(%{game_id: game_id, rounds: rounds}) do
    mins = %{"red" => 0, "green" => 0, "blue" => 0}

    for round <- rounds, reduce: mins do
      acc -> for draws <- round, reduce: acc do
        acc -> for {color, number} <- draws, reduce: acc do
            acc -> Map.update(acc, color, :nil, fn existing -> max(number, existing) end)
        end
      end
    end
  end
end

IO.puts("Result: #{App.process_file()}")

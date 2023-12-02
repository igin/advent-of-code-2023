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
    new_value = if is_game_possible?(game) do
      acc + game.game_id
    else
      acc
    end

    process_lines(rest, new_value)
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

  def is_game_possible?(%{game_id: game_id, rounds: rounds}) do
    Enum.all?(
      for round <- rounds, do: is_round_possible?(round)
    )
  end

  def is_round_possible?(rounds) do
    Enum.all?(
      for draws <- rounds, do: are_draws_possible?(draws)
    )
  end

  def are_draws_possible?(draws) do
    Enum.all?(
      for {color, number} <- draws, do: is_draw_possible?(color, number)
    )
  end

  def is_draw_possible?("red", number), do: number <= 12
  def is_draw_possible?("green", number), do: number <= 13
  def is_draw_possible?("blue", number), do: number <= 14


  def prepend_if_not_nil(:nil, rest), do: rest
  def prepend_if_not_nil(head, rest), do: [head | rest]
end

IO.puts("Result: #{App.process_file()}")

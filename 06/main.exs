defmodule App do
  def process_file do
    {:ok, text} = File.read("./input.txt")
    games = parse_games(text)
    Enum.product(Enum.map(games, fn game -> possibilities_for_record(game) end))
  end

  def parse_games(text) do
    [times_line, distances_line] = String.split(text, "\n", trim: true)
    times = Regex.scan(~r/([0-9]+)/, times_line, trim: true) |> Enum.map(fn [match, _] -> Integer.parse(match) |> elem(0) end)
    distances = Regex.scan(~r/([0-9]+)/, distances_line, trim: true) |> Enum.map(fn [match, _] -> Integer.parse(match) |> elem(0) end)
    Enum.zip(times, distances)
  end

  def possibilities_for_record({total_time, total_distance}) do
    Enum.sum(for t_button <- 0..total_time do
      reached_distance = t_button * total_time - t_button * t_button
      if reached_distance > total_distance do
        1
      else
        0
      end
    end)
  end
end

IO.inspect(App.process_file())

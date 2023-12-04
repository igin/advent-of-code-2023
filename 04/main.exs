defmodule App do
  def process_file do
    {:ok, text} = File.read("./input.txt")
    lines = String.split(text, "\n", trim: true)
    games = parse_games(lines)
    # compute_wins(games)
    {total_count, card_count_map} = compute_scratch_cards(games)
    IO.inspect(card_count_map)
    total_count
  end


  def parse_games(lines) do
    for line <- lines do
      [_, card_id, winning_numbers, card_numbers] = Regex.run(~r/Card\s+([0-9]+):(.*)\|(.*)/, line, trim: true)
      %{card_id: Integer.parse(card_id) |> elem(0), winning_numbers: parse_numbers(winning_numbers), card_numbers: parse_numbers(card_numbers)}
    end
  end

  def parse_numbers(string) do
    number_strings = String.split(string, " ", trim: true)
    numbers = for number_string <- number_strings do
      number_string
      |> Integer.parse()
      |> elem(0)
    end
    MapSet.new(numbers)
  end

  def compute_wins(games) do
    for game <- games, reduce: 0 do total ->
      winning_card_numbers = MapSet.intersection(game.winning_numbers, game.card_numbers)
      number_of_winning_numbers = MapSet.size(winning_card_numbers)
      total + cond do
        number_of_winning_numbers > 0 -> :math.pow(2, number_of_winning_numbers - 1) |> round()
        true -> 0
      end
    end
  end

  def compute_scratch_cards(games) do
    for game <- games, reduce: {0, %{}} do {total_count, card_count_map} ->
      winning_card_numbers = MapSet.intersection(game.winning_numbers, game.card_numbers)
      number_of_winning_numbers = MapSet.size(winning_card_numbers)

      card_instances = 1 + Map.get(card_count_map, game.card_id, 0)

      card_count_map = for card_index <- game.card_id..game.card_id+number_of_winning_numbers, reduce: card_count_map do card_count_map ->
        old_count = Map.get(card_count_map, card_index, 0)
        Map.put(card_count_map, card_index, old_count + card_instances)
      end

      {total_count + card_instances, card_count_map}
    end
  end

end

IO.puts("Result: #{App.process_file()}")

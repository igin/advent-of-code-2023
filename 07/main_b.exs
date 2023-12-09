defmodule App do
  def process_file do
    {:ok, text} = File.read("./input.txt")
    cards = parse_cards(text)
    sorted_cards = sort_cards(cards)
    total_bid(sorted_cards)
  end

  def parse_cards(text) do
    String.split(text, "\n") |> Enum.map(fn line -> Hand.from_line(line) end)
  end

  def sort_cards(cards) do
    type_groups = Enum.group_by(cards, fn card -> card.type end)
    for {type, hands} <- type_groups do
      sorted_hands = Enum.sort(hands, &(Hand.compare_values(&2, &1)))
      {type, sorted_hands}
    end
    |> Enum.sort_by(fn {type, _} -> type end)
    |> Enum.map(fn {_, hands} -> hands end)
    |> List.flatten()
  end

  def total_bid(cards) do
    Enum.sum(for {card, index} <- Enum.with_index(cards) do
      card.bid * (index + 1)
    end)
  end
end

defmodule Hand do
  defstruct [:cards, :card_values, :bid, :type]

  def from_line(line) do
    [cards_string, bid_string] = String.split(line, " ", trim: true)
    {bid, _} = Integer.parse(bid_string)
    cards = String.graphemes(cards_string)
    card_values = Enum.map(cards, fn card -> card_value(card) end)

    %Hand{
      cards: cards,
      card_values: card_values,
      bid: bid,
      type: type(card_values)
    }
  end

  defp card_value(card) do
    case card do
      "J" -> 1
      "2" -> 2
      "3" -> 3
      "4" -> 4
      "5" -> 5
      "6" -> 6
      "7" -> 7
      "8" -> 8
      "9" -> 9
      "T" -> 10
      "Q" -> 12
      "K" -> 13
      "A" -> 14
    end
  end

  defp type(card_values) do
    groups = Enum.group_by(card_values, fn val -> val end)
    num_jokers = Enum.count(Map.get(groups, 1, []))
    counts = Map.delete(groups, 1)
    |> Map.values()
    |> Enum.map(fn group -> Enum.count(group) end)
    |> Enum.sort()
    |> Enum.reverse()

    highest_count = Enum.at(counts, 0, 0)


    cond do
      highest_count + num_jokers == 5 -> 7
      highest_count + num_jokers == 4 -> 6
      highest_count + num_jokers == 3 && Enum.at(counts, 1) == 2 -> 5
      highest_count + num_jokers == 3 -> 4
      highest_count + num_jokers == 2 && Enum.at(counts, 1) == 2 -> 3
      highest_count + num_jokers == 2 -> 2
      highest_count + num_jokers == 1 -> 1
    end
  end

  def compare_values(%Hand{card_values: card_values_a}, %Hand{card_values: card_values_b}) do
    result = compare_digits(card_values_a, card_values_b)
    IO.inspect(%{a: card_values_a, b: card_values_b, result: result}, charlists: :as_lists)
    result
  end

  defp compare_digits([], []), do: true
  defp compare_digits([digit_a | rest_a], [digit_b | rest_b]) do
    IO.puts("Compare digit #{digit_a}, #{digit_b}")
    cond do
      digit_a > digit_b -> true
      digit_a < digit_b -> false
      true -> compare_digits(rest_a, rest_b)
    end
  end

end

IO.inspect(App.process_file(), charlists: :as_lists)

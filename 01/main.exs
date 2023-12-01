defmodule App do
  @digits %{
    one: 1,
    two: 2,
    three: 3,
    four: 4,
    five: 5,
    six: 6,
    seven: 7,
    eight: 8,
    nine: 9
  }

  def process_file do
    {:ok, text} = File.read("./input.txt")
    lines = String.split(text, "\n")
    process_lines(lines)
  end

  def process_lines(lines, acc \\ 0)
  def process_lines([], acc), do: acc
  def process_lines([line | rest], acc) do
    digits = find_digits(line)
    new_value = acc + Enum.at(digits, 0) * 10 + Enum.at(digits, -1)
    process_lines(rest, new_value)
  end

  def find_digits(string) do
    Enum.reverse(find_digits_rev(String.graphemes(string)))
  end

  def find_digits_rev(characters, found_digits \\ [])
  def find_digits_rev([], found_digits), do: found_digits
  def find_digits_rev([head | tail] = characters, found_digits) do
    first_digit = case Integer.parse(head) do
      {digit, _} -> digit
      :error -> starts_with_digit(characters)
    end

    find_digits_rev(tail, prepend_if_not_nil(first_digit, found_digits))
  end

  def starts_with_digit(characters) do
    string = Enum.join(characters)
    Enum.find_value(@digits, fn {digit_name, digit_value} ->
      String.starts_with?(string, to_string(digit_name)) && digit_value
    end)
  end

  def prepend_if_not_nil(:nil, rest), do: rest
  def prepend_if_not_nil(head, rest), do: [head | rest]
end

IO.puts("Result: #{App.process_file()}")

defmodule App do
  def process_file do
    {:ok, text} = File.read("./input.txt")
    lines = String.split(text, "\n", trim: true)
    board = parse_board(lines)
    adjacent_numbers_map = create_adjacent_numbers_map(lines, board)
    compute_gear_number_sum(lines, adjacent_numbers_map)
  end


  def parse_board(lines) do
    symbols = for {line, index} <- Enum.with_index(lines), reduce: %{} do acc ->
      matches = Regex.scan( ~r/[^0-9.]/, line, return: :index)
      line_index_set = for [{index, _}] <- matches, reduce: MapSet.new() do
        acc -> MapSet.put(acc, index)
      end
      Map.put(acc, index, line_index_set)
    end

    %{
      map_width: String.length(Enum.at(lines, 0)),
      map_height: Enum.count(lines),
      symbols: symbols
    }
  end

  def create_adjacent_numbers_map(lines, board) do
    value = for {line, line_index} <- Enum.with_index(lines), reduce: %{} do adjacent_numbers_map ->
      matches = Regex.scan( ~r/[0-9]+/, line, return: :index)
      adjacent_numbers_map = for [{index, length}] <- matches, reduce: adjacent_numbers_map do adjacent_numbers_map ->
        x_start = index - 1
        y_start = line_index - 1
        x_end = index + length
        y_end = line_index + 1

        number_string = String.slice(line, index..(index+length-1))
        {number, _} = Integer.parse(String.slice(line, index..(index+length-1)))
        for x <- x_start..x_end, reduce: adjacent_numbers_map do adjacent_numbers_map ->
          for y <- y_start..y_end, reduce: adjacent_numbers_map do adjacent_numbers_map ->
            cond do
              x >= index && x < index + length && y == y_start + 1 -> adjacent_numbers_map
              true -> add_adjacent_numbers(board, x, y, number, adjacent_numbers_map)
            end
          end
        end
      end
    end
  end

  def compute_gear_number_sum(lines, adjacent_numbers_map) do
    for {line, line_index} <- Enum.with_index(lines), reduce: 0 do total_sum ->
      matches = Regex.scan( ~r/[*]/, line, return: :index)
      for [{index, _}] <- matches, reduce: total_sum do total_sum ->
        adjacent_numbers = Map.get(adjacent_numbers_map, line_index) |> Map.get(index, [])
        if Enum.count(adjacent_numbers) == 2 do
          total_sum + Enum.product(adjacent_numbers)
        else
          total_sum
        end
      end
    end
  end

  def sum_components(lines, board) do
    for {line, line_index} <- Enum.with_index(lines), reduce: 0 do total_sum ->
      matches = Regex.scan( ~r/[0-9]+/, line, return: :index)
      total_sum + for [{index, length}] <- matches, reduce: 0 do acc ->
        x_start = index - 1
        y_start = line_index - 1
        x_end = index + length
        y_end = line_index + 1

        number_string = String.slice(line, index..(index+length-1))
        {number, _} = Integer.parse(String.slice(line, index..(index+length-1)))

        number_is_component = Enum.any?(for x <- x_start..x_end, reduce: [] do acc ->
          acc ++ for y <- y_start..y_end do
            board_has_component(board, x, y)
          end
        end)

        if number_is_component do
          acc + number
        else
          acc
        end
      end
    end
  end

  def board_has_component(%{map_width: map_width, map_height: map_height, symbols: symbols}, x, y) do
    cond do
      x < 0 -> false
      x > map_width - 1 -> false
      y < 0 -> false
      y > map_height - 1 -> false
      true ->
        Map.get(symbols, y) |> MapSet.member?(x)
    end
  end

  def add_adjacent_numbers(%{map_width: map_width, map_height: map_height, symbols: symbols}, x, y, component_number, gear_map) do
    cond do
      x < 0 -> gear_map
      x > map_width - 1 -> gear_map
      y < 0 -> gear_map
      y > map_height - 1 -> gear_map
      true ->
        current_y = Map.get(gear_map, y, %{})
        numbers = Map.get(current_y, x, [])
        new_numbers = [component_number | numbers]
        new_y = Map.put(current_y, x, new_numbers)
        Map.put(gear_map, y, new_y)
    end
  end

end

IO.puts("Result: #{App.process_file()}")

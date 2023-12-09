defmodule App do
  def process_file do
    {:ok, text} = File.read("./input.txt")
    %{seeds: seeds, mappings: mappings} = parse_almanac(text)
    ranges = parse_ranges(seeds)
    pass_ranges_through_almanac(ranges, mappings) |> get_minimum_value_of_ranges()
  end

  def parse_ranges(seeds) do
    pairs = Enum.chunk_every(seeds, 2)
    for [start, length] <- pairs do
      %{start: start, end: start + length - 1}
    end
  end

  def parse_almanac(text) do
    text = String.replace(text, "\n", " ")
    seeds = Regex.run(~r/seeds:([0-9\s]*)/, text) |> Enum.at(1) |> String.split(" ", trim: true) |> Enum.map(fn val -> val |> Integer.parse() |> elem(0) end)
    matches = Regex.scan(~r/([a-z\-]*) map:([0-9\s]*)/, text)

    mappings = Map.new(for {[_, map_name, map_values], index} <- Enum.with_index(matches) do
      numbers = String.split(map_values, " ", trim: true) |> Enum.map(fn val -> Integer.parse(val) |> elem(0) end)
      triplets = Enum.chunk_every(numbers, 3)
        |> Enum.map(fn [dest_start, src_start, length] -> %{source_start: src_start, destination_start: dest_start, length: length} end)
        |> Enum.sort_by(fn %{source_start: src_start} -> src_start end)

      {
        "#{index}_#{map_name}",
        triplets
      }
    end)

    %{
      seeds: seeds,
      mappings: mappings
    }
  end

  def get_minimum_value_of_ranges(ranges) do
    ranges |> Enum.map(&(&1.start)) |> Enum.min()
  end

  def mapping_to_source_range(%{source_start: src_start, length: length}) do
    %{start: src_start, end: src_start + length - 1}
  end

  def mapping_to_dest_range(%{destination_start: dst_start, length: length}) do
    %{start: dst_start, end: dst_start + length - 1}
  end

  def pass_ranges_through_almanac(ranges, almanac) do
    for {_, mappings} <- almanac, reduce: ranges do current_ranges ->
      pass_ranges_through_mappings(current_ranges, mappings)
    end
  end

  def pass_ranges_through_mappings(ranges, mappings) do
    List.flatten(for range <- ranges do
      pass_range_through_mappings(range, mappings)
    end)
  end

  def pass_range_through_mappings(range, []), do: [range]
  def pass_range_through_mappings(range, [current_map | rest]) do
    current_offset = current_map.destination_start - current_map.source_start
    {range_before, range_affected, range_after} = split_range_by_mapping(range, current_map)

    mapped_range_affected = if range_affected != :nil do offset_range(range_affected, current_offset) else :nil end
    mapped_ranges_after = if range_after != :nil do pass_range_through_mappings(range_after, rest) else [] end

    ([range_before, mapped_range_affected] ++ mapped_ranges_after) |> Enum.filter(&(&1 != :nil))
  end

  def split_range_by_mapping(range, current_map) do
    {
      range_before_mapping(range, current_map),
      range_in_mapping(range, current_map),
      range_after_mapping(range, current_map)
    }
  end

  def range_before_mapping(range, current_map) do
    if range.start < current_map.source_start do
      %{start: range.start, end: min(current_map.source_start - 1, range.end)}
    else
      :nil
    end
  end

  def range_in_mapping(range, current_map) do
    max_start = max(range.start, current_map.source_start)
    min_end = min(range.end, current_map.source_start + current_map.length - 1)

    if min_end >= max_start do
      %{start: max_start, end: min_end}
    else
      :nil
    end

  end

  def range_after_mapping(range, current_map) do
    if range.end > current_map.source_start + current_map.length - 1 do
      %{start: max(current_map.source_start + current_map.length, range.start), end: range.end}
    else
      :nil
    end
  end

  def offset_range(range, offset) do
    %{start: range.start + offset, end: range.end + offset}
  end
end

IO.inspect(App.process_file())

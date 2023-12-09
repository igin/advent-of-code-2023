defmodule App do
  def process_file do
    {:ok, text} = File.read("./input.txt")
    %{seeds: seeds, mappings: mappings} = parse_almanac(text)
    new_seeds = pass_seeds_through_almanac(seeds, mappings)

    ranges = parse_ranges(seeds)
    IO.puts("Parsed Ranges:")
    IO.inspect(ranges)
    new_ranges = pass_ranges_through_almanac(ranges, mappings)
    IO.puts("result ->")
    IO.inspect(new_ranges)
    Enum.min(new_seeds)
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

  def pass_seeds_through_almanac(seeds, almanac) do
    Enum.map(seeds, fn seed -> pass_value_through_almanac(seed, almanac) end)
  end

  def pass_value_through_almanac(value, almanac) do
    for {_, mappings} <- almanac, reduce: value do value ->
      pass_through_map(value, mappings)
    end
  end

  def pass_through_map(value, ranges)
  def pass_through_map(value, ranges) do
    applicable_ranges = Enum.filter(ranges, fn mapping -> is_in_range?(value, mapping) end)
    cond do
      Enum.count(applicable_ranges) == 0 -> value
      Enum.count(applicable_ranges) == 1 -> pass_through_mapping(value, Enum.at(applicable_ranges, 0))
      true -> :error
    end
  end

  def pass_through_mapping(value, range)
  def pass_through_mapping(value, %{
    source_start: source_start,
    destination_start: destination_start,
  }) do
      value - source_start + destination_start
    end

  def is_in_range?(value, range)
  def is_in_range?(value, %{source_start: source_start, length: length}) do
    value >= source_start && value < source_start + length
  end


  def subtract_range(a, b) do
    cond do
      a.end < b.start -> []
      b.end < a.start -> []
      a.start == b.start && a.end == b.end -> []
      b.start <= a.start && b.end >= a.end -> []
      a.start < b.start && a.end <= b.end -> [%{start: a.start, end: b.start - 1}]
      a.end > b.end && a.start >= b.start -> [%{start: b.end + 1, end: a.end}]
      a.start < b.start && a.end > b.end -> [%{start: a.start, end: b.start - 1}, %{start: b.end + 1, end: a.end}]
      true -> throw("Got unexpected range")
    end
  end

  def intersect_range(a, b) do
    cuttings = subtract_range(a, b)
    range = for cut <- cuttings, reduce: a do range ->
      case range do
        :nil -> :nil
        _ -> rest = subtract_range(range, cut)
          case Enum.count(rest) do
            1 -> Enum.at(rest, 0)
            0 -> :nil
            _ -> throw("Got wrong amount of ranges in intersect")
          end
      end
    end

    if Enum.count(cuttings) > 0 do
      [range]
    else
      []
    end
  end

  def merge_ranges(ranges) do
    points = List.flatten(for range <- ranges do
      [%{value: range.start, type: :start}, %{value: range.end, type: :end}]
    end) |> Enum.sort_by(fn item -> item.value end)

    counts = Enum.scan(points, 0 , fn point, stack_count ->
      case point.type do
        :start -> stack_count + 1
        :end -> stack_count - 1
      end
    end)

    filtered_points = Enum.filter(Enum.zip(points, counts), fn {point, stack_count} -> case point.type do
      :start -> stack_count == 1
      :end -> stack_count == 0
      end
    end)

    pairs = Enum.chunk_every(filtered_points, 2)
    for [{start_point, _}, {end_point, _}] <- pairs do
      %{start: start_point.value, end: end_point.value}
    end
  end

  def offset_range(range, offset) do
    %{
      start: range.start + offset,
      end: range.end + offset
    }
  end

  def pass_ranges_through_almanac(ranges, maps) do
    for {map_name, map} <- maps, reduce: ranges do current_ranges ->
      IO.puts(map_name)

      mapped_ranges = List.flatten(for range <- current_ranges do pass_range_through_mappings(range, map) end)
      IO.puts("mapped ranges")
      IO.inspect(mapped_ranges)
      consolidated_ranges = merge_ranges(mapped_ranges)
      IO.puts("consolidated ranges")
      IO.inspect(consolidated_ranges)
      consolidated_ranges
    end
  end

  def pass_range_through_mappings(range, mappings) do
    mapped_ranges = for mapping <- mappings do
        pass_range_through_mapping(range, mapping)
    end |> List.flatten()

    mapping_ranges = Enum.map(mappings, fn map -> %{start: map.source_start, end: map.source_start + map.length - 1} end)
    unmapped_ranges = subtract_ranges(range, mapping_ranges)
    IO.inspect(%{unmapped: unmapped_ranges})

    mapped_ranges ++ unmapped_ranges
  end

  def subtract_ranges(original, subtractors) do
    subtractor_points = List.flatten(for range <- subtractors do
      [%{value: range.start, type: :start_subtractor}, %{value: range.end, type: :end_subtractor}]
    end)

    original_points = [%{value: original.start, type: :start_original}, %{value: original.end, type: :end_original}]
    points = original_points ++ subtractor_points
    sorted_points = points |> Enum.sort_by(fn point -> point.value end)

    IO.inspect(%{original: original})

    counts = Enum.scan(sorted_points, 0 , fn point, stack_count ->
      case point.type do
        :start_original -> stack_count + 1
        :end_original -> stack_count - 1
        :start_subtractor -> stack_count - 1
        :end_subtractor -> stack_count + 1
      end
    end)

    IO.inspect(Enum.zip(sorted_points, counts))

    filtered_points = Enum.filter(Enum.zip(sorted_points, counts), fn {point, stack_count} -> case point.type do
      :start_original -> stack_count == 1
      :end_original -> stack_count == 0
      :start_subtractor -> stack_count == 0
      :end_subtractor -> stack_count == 1
      _ -> false
      end
    end)

    pairs = Enum.chunk_every(filtered_points, 2)
    for [{start_point, _}, {end_point, _}] <- pairs do
      %{start: start_point.value, end: end_point.value}
    end
  end

  def subtract_mapping_from_range(range, %{
    source_start: source_start,
    destination_start: destination_start,
    length: length
  }) do
    subtract_range(range, %{start: source_start, end: source_start + length - 1})
  end

  def pass_range_through_mapping(range, %{
    source_start: source_start,
    destination_start: destination_start,
    length: length
  }) do
    affected_ranges = intersect_range(%{start: source_start, end: source_start + length - 1}, range)
    # IO.puts("input range")
    # IO.inspect(range)
    # IO.puts("mapping range")
    # IO.inspect(%{start: source_start, end: source_start + length - 1})
    # IO.puts("affected range")
    # IO.inspect(affected_ranges)
    # IO.puts("Offset: #{destination_start - source_start}")
    mapped_range = Enum.map(affected_ranges, fn range -> offset_range(range, destination_start - source_start) end)
  end

  def test() do
    {:ok, text} = File.read("./input.txt")
    %{seeds: seeds, mappings: mappings} = parse_almanac(text)
    input_ranges = [%{start: 46, end: 49}, %{start: 54, end: 62}, %{start: 74, end: 87},  %{start: 90, end: 100}]
    {_, map} = Enum.filter(mappings, fn {map_name, _} -> map_name == "4_light-to-temperature" end) |> Enum.at(0)

    mapped_ranges = List.flatten(for range <- input_ranges do pass_range_through_mappings(range, map) end)
    IO.puts("mapped ranges")
    IO.inspect(mapped_ranges)
    consolidated_ranges = merge_ranges(mapped_ranges)
    IO.puts("consolidated ranges")
    IO.inspect(consolidated_ranges)
    consolidated_ranges

  end

end

App.test()

ExUnit.start()

Code.require_file("./main_part2_try2.exs")

ExUnit.start()

defmodule RangeSplitTest do
  use ExUnit.Case

  test "test1" do
    mapping = %{source_start: 32, length: 1}
    range = %{start: 30, end: 32}

    assert App.split_range_by_mapping(range, mapping) == {
      %{start: 30, end: 31},
      %{start: 32, end: 32},
      :nil
    }
  end

  test "test2" do
    mapping = %{source_start: 32, length: 10}
    range = %{start: 30, end: 42}

    assert App.split_range_by_mapping(range, mapping) == {
      %{start: 30, end: 31},
      %{start: 32, end: 41},
      %{start: 42, end: 42}
    }
  end


  test "test3" do
    mapping = %{source_start: 10, length: 10}
    range = %{start: 0, end: 30}

    assert App.split_range_by_mapping(range, mapping) == {
      %{start: 0, end: 9},
      %{start: 10, end: 19},
      %{start: 20, end: 30}
    }
  end
end

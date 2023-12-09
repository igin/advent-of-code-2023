defmodule App do
  def process_file do
    {:ok, text} = File.read("./input.txt")
    lines = String.split(text, "\n", trim: true)
    histories = for line <- lines do
      SensorHistory.parse(line)
    end

    result_a = for history <- histories do
      SensorHistory.predict_next_value(history)
    end |> Enum.sum()

    result_b = for history <- histories do
      SensorHistory.predict_previous_value(history)
    end |> Enum.sum()

    %{result_a: result_a, result_b: result_b}
  end
end

defmodule SensorHistory do
  defstruct [:values]

  def parse(line) do
    %SensorHistory{
      values: String.split(line) |> Enum.map(fn value -> Integer.parse(value) |> elem(0) end)
    }
  end

  def compute_derivatives(%SensorHistory{values: values}) do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.scan(values, fn _, last_values -> compute_derivative(last_values) end)
    |> Stream.take_while(fn values -> !Enum.all?(values, &(&1 == 0)) end)
    |> Enum.to_list()
  end

  def compute_derivative([_ | rest] = values) do
    Enum.zip_with(values, rest, fn a, b -> b - a end)
  end

  def predict_next_value(%SensorHistory{values: values} = history) do
    [values | compute_derivatives(history)]
    |> Enum.map(&(Enum.reverse(&1)))
    |> Enum.map(&(Enum.at(&1, 0)))
    |> Enum.reduce(0, fn a, b -> a + b end)
  end

  def predict_previous_value(%SensorHistory{values: values} = history) do
    [values | compute_derivatives(history)]
    |> Enum.map(&(Enum.at(&1, 0)))
    |> Enum.reverse()
    |> Enum.reduce(0, fn element, acc -> element - acc end)
  end
end







IO.inspect(App.process_file(), charlists: :as_lists)

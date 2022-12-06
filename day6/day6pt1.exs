defmodule Day6 do
  def get_input do
    File.read!("./day6/day6input.txt")
  end

  def main do
    charList = get_input()
    |> String.split("", trim: true)

    Enum.reduce_while(3..length(charList) |> Enum.to_list(), 3, fn x, acc ->
      uniquedCount = Enum.slice(charList, x-3, 4) |> Enum.uniq() |> Enum.count()

      if (uniquedCount == 4) do
        {:halt, acc}
      else
        {:cont, acc + 1}
      end

    end)
  end
end

IO.inspect(Day6.main() + 1)






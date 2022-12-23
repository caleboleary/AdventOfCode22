defmodule Day6 do
  def get_input do
    File.read!("./day6/day6input.txt")
  end

  def main do
    charList = get_input()
    |> String.split("", trim: true)

    Enum.reduce_while(13..length(charList) |> Enum.to_list(), 13, fn x, acc ->
      uniquedCount = Enum.slice(charList, x-13, 14) |> Enum.uniq() |> Enum.count()

      if (uniquedCount == 14) do
        {:halt, acc}
      else
        {:cont, acc + 1}
      end

    end)
  end
end

IO.inspect(Day6.main() + 1)
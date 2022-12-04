defmodule Day4 do
  def get_input do
    File.read!("./day4/day4input.txt")
  end

  def main do
    input = get_input()

    String.split(input, "\n", trim: true)
    |> Enum.map(fn i -> String.split(i, ",", trim: true) end)
    |> Enum.map(fn pair ->
      one = String.split(Enum.at(pair, 0), "-", trim: true)
      two = String.split(Enum.at(pair, 1), "-", trim: true)

      # [1-2, 8-9]
      # [1-3, 2-9]

      if (String.to_integer(Enum.at(one, 0)) < String.to_integer(Enum.at(two, 0)) &&
            String.to_integer(Enum.at(one, 1)) < String.to_integer(Enum.at(two, 0))) ||
           (String.to_integer(Enum.at(one, 0)) > String.to_integer(Enum.at(two, 1)) &&
              String.to_integer(Enum.at(one, 1)) > String.to_integer(Enum.at(two, 1))) do
        0
      else
        1
      end
    end)
    |> Enum.reduce(0, fn a, b -> a + b end)
  end
end

IO.inspect(Day4.main())
defmodule Day10 do
  def get_input do
    # File.read!("./day10/day10testinput2.txt")
    # File.read!("./day10/day10testinput.txt")
    File.read!("./day10/day10input.txt")
        |> String.split("\n", trim: true)
  end


  def main do
    input = get_input()
    
    xValues = Enum.reduce(input, [1], fn command, acc ->
      if command === "noop" do
        acc ++ [acc |> Enum.at(-1)]
      else
        [_, addValue] = String.split(command, " ")
        acc ++ [acc |> Enum.at(-1), (acc |> Enum.at(-1)) + String.to_integer(addValue)]
        
      end
    end)

    [
        20 * Enum.at(xValues, 19),
        60 * Enum.at(xValues, 59),
        100 * Enum.at(xValues, 99),
        140 * Enum.at(xValues, 139),
        180 * Enum.at(xValues, 179),
        220 * Enum.at(xValues, 219),
    ] |> Enum.reduce(0, fn x, acc -> acc + x end)

  end
end

IO.inspect(Day10.main())
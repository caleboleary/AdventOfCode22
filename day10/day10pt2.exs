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

    xValues 
      |> Enum.with_index()
      |> Enum.map(fn {spritePos, index} -> 
        if abs(spritePos - rem(index, 40)) < 2 do
          "#"
        else
          "."
        end
      end)
      |> Enum.chunk_every(40)
      |> Enum.map(fn x -> x |> Enum.join() end)

  end
end

IO.inspect(Day10.main())
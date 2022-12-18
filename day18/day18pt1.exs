defmodule Day18 do
  def get_input do
    # File.read!("./day18/day18testinput2.txt")
    File.read!("./day18/day18testinput.txt")
    # File.read!("./day18/day18input.txt")
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          line
          |> String.split(",", trim: true)
          |> Enum.map(fn x -> String.to_integer(x) end)
          |> List.to_tuple()
        end)
  end

  def indexOf(string, substr) do
    split = String.split(string, substr)
    if length(split) == 1 do
        -1
    else
        String.length(split |> List.first) + 1
    end
  end

  def get_adjacent_faces({x,y,z}) do
    [
      {x-1, y, z},
      {x+1, y, z},
      {x, y-1, z},
      {x, y+1, z},
      {x, y, z-1},
      {x, y, z+1}
    ]
  end


  def main do
    input = get_input()

    Enum.reduce(input, 0, fn line, acc ->
      adjFaces = get_adjacent_faces(line)

      Enum.reduce(adjFaces, acc, fn face, acc2 ->
        if Enum.member?(input, face) do
          acc2
        else
          acc2 + 1
        end
      end)
    end)
    
    

  end
end

IO.inspect(Day18.main())
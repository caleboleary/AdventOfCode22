defmodule Day18 do
  def get_input do
    # File.read!("./day18/day18testinput2.txt")
    # File.read!("./day18/day18testinput.txt")
    File.read!("./day18/day18input.txt")
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          line
          |> String.split(",", trim: true)
          |> Enum.map(fn x -> String.to_integer(x) end)
          |> List.to_tuple()
        end)
  end

  

  def get_cavern(origin, input, {maxX, maxY, maxZ}) do
  
    cavern = [origin]

    Enum.reduce_while(0..100, cavern, fn _, acc ->
      adjFaces = Enum.flat_map(acc, fn face ->
        get_adjacent_faces(face)
      end)
      |> Enum.uniq()

      # IO.inspect(adjFaces)

      filteredFaces = Enum.filter(adjFaces, fn face ->
        if (
          Enum.member?(input, face)
          or Enum.member?(acc, face)
          or face |> elem(0) < 0
          or face |> elem(1) < 0
          or face |> elem(2) < 0
          or face |> elem(0) > maxX
          or face |> elem(1) > maxY
          or face |> elem(2) > maxZ 
        ) do
          false
        else
          true
        end
      end)

      if length(filteredFaces) > 0 do
        {:cont, filteredFaces ++ acc}
      else
        {:halt, acc}
      end
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

    maxX = input |> Enum.map(fn {x,_,_} -> x end) |> Enum.max()
    maxY = input |> Enum.map(fn {_,y,_} -> y end) |> Enum.max()
    maxZ = input |> Enum.map(fn {_,_,z} -> z end) |> Enum.max()

    IO.inspect({maxX, maxY, maxZ})

    Enum.reduce(input, %{
      caverns: [],
      exposedFaceCount: 0
    }, fn line, acc ->
      IO.inspect(line)
      adjFaces = get_adjacent_faces(line)
      IO.inspect(length(acc.caverns))

      exploration = Enum.reduce(adjFaces, acc, fn face, acc2 ->
        if Enum.member?(input, face) do
          acc2
        else
          # we've found an air slot
          # we need to recursively explore air it touches to see if it's connected to the outside
          # if we can find a chain of air pockets which get to x < 0 or y < 0 or z < 0, then we know it's connected to the outside
          # also, if we can find a chain of air pockets which get to x > maxX or y > maxY or z > maxZ, same as above
          
          # if this face is already listed in any explored caverns, then we don't need to explore it again

          prevExploredCavern = Enum.find(acc2.caverns, fn cavern -> Enum.member?(cavern.points, face) end)

          if prevExploredCavern != nil do
            if prevExploredCavern.touchesAir do
              %{
                caverns: acc2.caverns,
                exposedFaceCount: acc2.exposedFaceCount + 1
              }
            else
              %{
                caverns: acc2.caverns,
                exposedFaceCount: acc2.exposedFaceCount
              }
            end
          else
            cavern = get_cavern(face, input, {maxX, maxY, maxZ})
          
            #get caverns min x, y, z and max x, y, z
            cMinx = cavern |> Enum.map(fn {x,_,_} -> x end) |> Enum.min()
            cMiny = cavern |> Enum.map(fn {_,y,_} -> y end) |> Enum.min()
            cMinz = cavern |> Enum.map(fn {_,_,z} -> z end) |> Enum.min()
            cMaxx = cavern |> Enum.map(fn {x,_,_} -> x end) |> Enum.max()
            cMaxy = cavern |> Enum.map(fn {_,y,_} -> y end) |> Enum.max()
            cMaxz = cavern |> Enum.map(fn {_,_,z} -> z end) |> Enum.max()

            if cMinx <= 0 or cMiny <= 0 or cMinz <= 0 or cMaxx >= maxX or cMaxy >= maxY or cMaxz >= maxZ do
              %{
                caverns: acc2.caverns ++ [%{points: cavern, touchesAir: true}],
                exposedFaceCount: acc2.exposedFaceCount + 1
              }
            else
              %{
                caverns: acc2.caverns ++ [%{points: cavern, touchesAir: false}],
                exposedFaceCount: acc2.exposedFaceCount
              }
            end
          end

        end
      end)
    end)
    
    

  end
end

IO.inspect(Day18.main())
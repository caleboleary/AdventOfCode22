defmodule Day22 do
  def get_input do
    # File.read!("./day22/day22testinput.txt")
    File.read!("./day22/day22input.txt")
  end

  def parse_input(input) do
    [map, instructions] = input |> String.split("\n\n", trim: true)

    formattedMap = map |> String.split("\n", trim: true) |> Enum.map(fn x -> String.split(x, "", trim: true) end)

    longestLineLen = formattedMap |> Enum.map(fn x -> length(x) end) |> Enum.max()
    
    mapWithEqualLengthLines = formattedMap |> Enum.map(fn x -> x ++ List.duplicate(" ", longestLineLen - length(x)) end)

    parsedInstructions = String.split(instructions, ~r/[R|L]/, include_captures: true, trim: true)

    {mapWithEqualLengthLines, parsedInstructions}
  end

  def visualize_map(map) do
    # IO.inspect("---------------------------")
    # map |> Enum.map(fn x -> x |> Enum.join() |> IO.inspect() end)
    # IO.inspect("---------------------------")
  end

  def move_player_from_to(map, {fromx, fromy}, {tox, toy}) do
    # IO.inspect("moving player from")
    # IO.inspect({fromx, fromy})
    # IO.inspect("to")
    # IO.inspect({tox, toy})

    removed = map |> Enum.with_index() |> Enum.map(fn {row, i} -> 
      if i == fromy do
        Enum.with_index(row) |> Enum.map(fn {cell, j} -> 
          if j == fromx do
            "."
          else
            cell
          end
        end)
      else
        row
      end
    end)

    added = removed |> Enum.with_index() |> Enum.map(fn {row, i} -> 
      if i == toy do
        Enum.with_index(row) |> Enum.map(fn {cell, j} -> 
          if j == tox do
            "P"
          else
            cell
          end
        end)
      else
        row
      end
    end)
    
  end

  def apply_rotation(heading, rotation) do
    case rotation do
      "R" -> case heading do
        "U" -> "R"
        "R" -> "D"
        "D" -> "L"
        "L" -> "U"
      end
      "L" -> case heading do
        "U" -> "L"
        "L" -> "D"
        "D" -> "R"
        "R" -> "U"
      end
    end
  end

  def get_current_player_coords(map) do
    y = map |> Enum.find_index(fn x -> x |> Enum.find_index(fn y -> y == "P" end) != nil end)
    x = map |> Enum.at(y) |> Enum.find_index(fn x -> x == "P" end)
    {x, y}
  end

  def get_face_topleft(map, faceId) do
    if (length(map) < 50) do
      #sample
      cond do
        faceId == 1 -> {8, 0}
        faceId == 2 -> {0, 4}
        faceId == 3 -> {4, 4}
        faceId == 4 -> {8, 4}
        faceId == 5 -> {8, 8}
        faceId == 6 -> {12, 8}
      end
    else
      #real
      cond do
        faceId == 1 -> {50, 0}
        faceId == 2 -> {100, 0}
        faceId == 3 -> {50, 50}
        faceId == 4 -> {0, 100}
        faceId == 5 -> {50, 100}
        faceId == 6 -> {0, 150}
      end
    end
  end

  def get_current_face_id(map, {x, y}) do
    #don't love this, would love to be able to scan and then 3d fold any cube, but I can't even begin to think about how to do that hah
    if (length(map) < 50) do
      #sample
      cond do
        y < 4 -> 1
        y < 8 and x < 4 -> 2
        y < 8 and x < 8 -> 3
        y < 8 -> 4
        y < 12 and x < 12 -> 5
        y < 12 -> 6
      end

    else
      #real
      cond do
        y < 50 and x < 100 -> 1
        y < 50 -> 2
        y < 100 -> 3
        x < 50 and y < 150 -> 4
        y < 150 -> 5
        true -> 6
      end


    end
  end

  # call this func if we encounter " " or end of line/row to get next coords
  def handle_edge_warp(map, heading, {x, y}) do

    faceLen = if (length(map) < 50) do
      4
    else
      50
    end

    edgeCons = if faceLen == 4 do
      %{
        {1, "U"} => %{
          newLoc: 2,
          newHeading: "D",
          rot: 180, 
        },
        {1, "L"} => %{
          newLoc: 3,
          newHeading: "D", 
          rot: 270
        },
        {1, "R"} => %{
          newLoc: 6,
          newHeading: "L",
          rot: 180
        },
        {2, "U"} => %{
          newLoc: 1,
          newHeading: "U",
          rot: 180
        },
        {2, "L"} => %{
          newLoc: 6,
          newHeading: "U",
          rot: 90
        },
        {2, "D"} => %{
          newLoc: 5,
          newHeading: "U",
          rot: 180
        },
        {3, "U"} => %{
          newLoc: 1,
          newHeading: "R",
          rot: 90
        },
        {3, "D"} => %{
          newLoc: 5,
          newHeading: "R",
          rot: 270
        },
        {4, "R"} => %{
          newLoc: 6,
          newHeading: "D",
          rot: 90
        },
        {5, "L"} => %{
          newLoc: 3,
          newHeading: "U",
          rot: 270
        },
        {5, "D"} => %{
          newLoc: 2,
          newHeading: "U",
          rot: 180
        },
        {6, "U"} => %{
          newLoc: 4,
          newHeading: "L",
          rot: 270
        },
        {6, "R"} => %{
          newLoc: 1,
          newHeading: "L",
          rot: 180
        },
        {6, "D"} => %{
          newLoc: 2,
          newHeading: "R",
          rot: 90
        }     
      }
    else
      %{
        {1, "U"} => %{
          newLoc: 6,
          newHeading: "R",
          rot: 90, 
        },
        {1, "L"} => %{
          newLoc: 4,
          newHeading: "R",
          rot: 180
        },
        {2, "U"} => %{
          newLoc: 6,
          newHeading: "U",
          rot: 0
        },
        {2, "R"} => %{
          newLoc: 5,
          newHeading: "L",
          rot: 180
        },
        {2, "D"} => %{
          newLoc: 3,
          newHeading: "L",
          rot: 90
        },
        {3, "L"} => %{
          newLoc: 4,
          newHeading: "D",
          rot: 270
        },
        {3, "R"} => %{
          newLoc: 2,
          newHeading: "U",
          rot: 270
        },
        {4, "L"} => %{
          newLoc: 1,
          newHeading: "R",
          rot: 180
        },
        {4, "U"} => %{
          newLoc: 3,
          newHeading: "R",
          rot: 90
        },
        {5, "R"} => %{
          newLoc: 2, 
          newHeading: "L",
          rot: 180
        },
        {5, "D"} => %{
          newLoc: 6,
          newHeading: "L",
          rot: 90
        },
        {6, "R"} => %{
          newLoc: 5,
          newHeading: "U",
          rot: 270
        },
        {6, "D"} => %{
          newLoc: 2,
          newHeading: "D",
          rot: 0
        },
        {6, "L"} => %{
          newLoc: 1,
          newHeading: "D",
          rot: 270
        }
      }
        
    end

    IO.inspect("currpos")
    IO.inspect({x, y})

    currFace = get_current_face_id(map, {x, y})
    currFaceTopLeft = get_face_topleft(map, currFace)

    IO.inspect("currFace")
    IO.inspect(currFace)
    IO.inspect("currFaceTopLeft")
    IO.inspect(currFaceTopLeft)

    IO.inspect({x, y})



    connection = edgeCons |> Map.get({currFace, heading})

    visualize_map(map)
    IO.inspect(heading)

    IO.inspect("connection")
    IO.inspect(connection)

    newFaceTopLeft = get_face_topleft(map, connection.newLoc)

    currPositionOnFace = {x - (currFaceTopLeft |> elem(0)), y - (currFaceTopLeft |> elem(1))}
    IO.inspect("currPositionOnFace")
    IO.inspect(currPositionOnFace)

    rotatedCurrPos = case connection.rot do
      0 -> currPositionOnFace
      90 -> {(faceLen - 1) - (currPositionOnFace |> elem(1)), currPositionOnFace |> elem(0)}
      180 -> {(faceLen - 1) - (currPositionOnFace |> elem(0)), (faceLen - 1) - (currPositionOnFace |> elem(1))}
      270 -> {currPositionOnFace |> elem(1), (faceLen - 1) - (currPositionOnFace |> elem(0))}
    end

    IO.inspect("rotatedCurrPos")
    IO.inspect(rotatedCurrPos)

    # use rot, heading, currPosOnFace, and newFaceTopLeft to get new coords as the point travels over the edge to the next face of the cube
    newPoint = case connection.newHeading do
      "D" -> {rotatedCurrPos |> elem(0), 0}
      "R" -> {0, rotatedCurrPos |> elem(1)}
      "U" -> {rotatedCurrPos |> elem(0), faceLen - 1}
      "L" -> {faceLen - 1, rotatedCurrPos |> elem(1)}

    end

    IO.inspect("newPoint")
    IO.inspect(newPoint)

    newPointOnFullMap = {(newFaceTopLeft |> elem(0)) + (newPoint |> elem(0)), (newFaceTopLeft |> elem(1)) + (newPoint |> elem(1))}

    IO.inspect("newPointOnFullMap")
    IO.inspect(newPointOnFullMap)

    #return heading and new point
    {connection.newHeading, newPointOnFullMap}


  end

  def get_next_cell_coords(map, heading) do
    {x, y} = get_current_player_coords(map)
    case heading do
      "U" -> 
        if y - 1 > -1 and Enum.at(map |> Enum.at(y - 1), x) != " " do
          {"U", {x, y - 1}}
        else
          handle_edge_warp(map, heading, {x, y})
        end
      "R" ->
        if x + 1 < length(map |> Enum.at(0)) and Enum.at(map |> Enum.at(y), x + 1) != " " do
          {"R", {x + 1, y}}
        else
          handle_edge_warp(map, heading, {x, y})
        end
      "D" ->
        if y + 1 < length(map) and Enum.at(map |> Enum.at(y + 1), x) != " " do
          {"D", {x, y + 1}}
        else
          handle_edge_warp(map, heading, {x, y})
        end
      "L" ->
        if x - 1 > -1 and Enum.at(map |> Enum.at(y), x - 1) != " " do
          {"L", {x - 1, y}}
        else
         handle_edge_warp(map, heading, {x, y})
        end
     
    end
  end

  def apply_translation(map, heading, distance) do
    Enum.reduce_while(1..String.to_integer(distance), {heading, map}, fn _index, {transitionalHeading, transitionalMap} -> 

      visualize_map(transitionalMap)

      #get P x and y
      {x, y} = get_current_player_coords(transitionalMap)
      
      # IO.inspect("P is at")
      # IO.inspect({x, y})

      #get the next cell in the direction of the heading
      #TODO: mod stuff
      {nextHeading, next} = get_next_cell_coords(transitionalMap, transitionalHeading)
      # IO.inspect("next is")
      # IO.inspect(next)

      #get the next cell
      nextCell = transitionalMap |> Enum.at(next |> elem(1)) |> Enum.at(next |> elem(0))
      # IO.inspect("next cell is")
      # IO.inspect(nextCell)

      newMap = cond do
        nextCell == "." -> move_player_from_to(transitionalMap, {x, y}, next)
        nextCell == "#" -> transitionalMap #do nothing
      end

      # visualize_map(newMap)
      
      if (nextCell == "#") do
        {:halt, {transitionalHeading, newMap}}
      else
        {:cont, {nextHeading, newMap}}
      end

    end)
  end

  def apply_instruction(map, heading, "R") do
    {apply_rotation(heading, "R"), map}
  end

  def apply_instruction(map, heading, "L") do
    {apply_rotation(heading, "L"), map}
  end

  def apply_instruction(map, heading, distance) do
    {newHeading, newMap} = apply_translation(map, heading, distance)
  end


  def main do
    input = get_input()

    {baseMap, instructions} = parse_input(input)

    heading = "R";
    initialPosition = Enum.at(baseMap, 0) |> Enum.find_index(fn x -> x == "." end)

    #replace the initial position with a P
    map = Enum.with_index(baseMap) |> Enum.map(fn {row, i} -> 
      if i == 0 do
        Enum.with_index(row) |> Enum.map(fn {cell, j} -> 
          if j == initialPosition do
            "P"
          else
            cell
          end
        end)
      else
        row
      end
    end)

    visualize_map(map)



    {finalHeading, finalMap} = Enum.reduce(instructions, {heading, map}, fn instruction, acc ->
      {heading, map} = acc

      res = apply_instruction(map, heading, instruction)

      IO.inspect("an instruction was applied")
      res
      # IO.inspect(res)
      
    end)


    visualize_map(finalMap)
    IO.inspect(finalHeading)

    finalHeadingValue = case finalHeading do
      "R" -> 0
      "D" -> 1
      "L" -> 2
      "U" -> 3
    end


    {finalX, finalY} = get_current_player_coords(finalMap)

    IO.inspect({finalX, finalY, finalHeadingValue})

    (1000 * (finalY + 1)) + (4 * (finalX + 1)) + finalHeadingValue
    

  end
end

IO.inspect(Day22.main())
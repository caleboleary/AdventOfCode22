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
    IO.inspect("---------------------------")
    map |> Enum.map(fn x -> x |> Enum.join() |> IO.inspect() end)
    IO.inspect("---------------------------")
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

  def get_next_cell_coords(map, heading) do
    {x, y} = get_current_player_coords(map)
    case heading do
      "U" -> 
        if y - 1 > -1 and Enum.at(map |> Enum.at(y - 1), x) != " " do
          {x, y - 1}
        else
          #from the bottom, moving upwards, get the coords of the first non space char
          Enum.map(length(map) - 1..0, fn i -> 
            if Enum.at(map |> Enum.at(i), x) != " " do
              {x, i}
            end
          end) |> Enum.find(fn x -> x != nil end)
        end
      "R" ->
        if x + 1 < length(map |> Enum.at(0)) and Enum.at(map |> Enum.at(y), x + 1) != " " do
          {x + 1, y}
        else
          #from the left, moving right, get the coords of the first non space char
          Enum.map(0..length(map |> Enum.at(0)) - 1, fn i -> 
            if Enum.at(map |> Enum.at(y), i) != " " do
              {i, y}
            end
          end) |> Enum.find(fn x -> x != nil end)
        end
      "D" ->
        if y + 1 < length(map) and Enum.at(map |> Enum.at(y + 1), x) != " " do
          {x, y + 1}
        else
          #from the top, moving downwards, get the coords of the first non space char
          Enum.map(0..length(map) - 1, fn i -> 
            if Enum.at(map |> Enum.at(i), x) != " " do
              {x, i}
            end
          end) |> Enum.find(fn x -> x != nil end)
        end
      "L" ->
        if x - 1 > -1 and Enum.at(map |> Enum.at(y), x - 1) != " " do
          {x - 1, y}
        else
          #from the right, moving left, get the coords of the first non space char
          Enum.map(length(map |> Enum.at(0)) - 1..0, fn i -> 
            if Enum.at(map |> Enum.at(y), i) != " " do
              {i, y}
            end
          end) |> Enum.find(fn x -> x != nil end)
        end
     
    end
  end

  def apply_translation(map, heading, distance) do
    Enum.reduce_while(1..String.to_integer(distance), map, fn _index, acc -> 

      #get P x and y
      {x, y} = get_current_player_coords(acc)
      # IO.inspect("P is at")
      # IO.inspect({x, y})

      #get the next cell in the direction of the heading
      #TODO: mod stuff
      next = get_next_cell_coords(acc, heading)
      # IO.inspect("next is")
      # IO.inspect(next)

      #get the next cell
      nextCell = acc |> Enum.at(next |> elem(1)) |> Enum.at(next |> elem(0))
      # IO.inspect("next cell is")
      # IO.inspect(nextCell)

      newAcc = cond do
        nextCell == "." -> move_player_from_to(acc, {x, y}, next)
        nextCell == "#" -> acc #do nothing
      end

      # visualize_map(newAcc)
      
      if (nextCell == "#") do
        {:halt, newAcc}
      else
        {:cont, newAcc}
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
    {heading, apply_translation(map, heading, distance)}
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
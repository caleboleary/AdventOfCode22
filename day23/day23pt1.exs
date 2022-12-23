defmodule Day23 do
  def get_input do
    # File.read!("./day23/day23testinput.txt")
    File.read!("./day23/day23input.txt")
        |> String.split("\n", trim: true)
        |> Enum.map(fn x -> String.split(x, "", trim: true) end)
  end

  def visualize_map(map) do
    IO.inspect("---------------------------")
    map |> Enum.map(fn x -> x |> Enum.join() |> IO.inspect() end)
    IO.inspect("---------------------------")
  end

  def get_padded_grid(input) do
    padAmt = 25
    topBottomPadRow = List.duplicate(".", (padAmt * 2) + Enum.count(Enum.at(input, 0)))
    leftRightPadRow = List.duplicate(".", padAmt)

    List.duplicate(topBottomPadRow, padAmt)
    ++ Enum.map(input, fn x -> leftRightPadRow ++ x ++ leftRightPadRow end)
    ++ List.duplicate(topBottomPadRow, padAmt)
  end

  def move_elf_from_to(map, {fromx, fromy}, {tox, toy}) do

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
            "#"
          else
            cell
          end
        end)
      else
        row
      end
    end)
      
  end

  def main do
    input = get_input()
    paddedGrid = get_padded_grid(input)
    visualize_map(paddedGrid)

    stepOrder = [
      :north,
      :south,
      :west,
      :east
    ]

    result = Enum.reduce(0..9, %{
      map: paddedGrid,
      stepOrder: stepOrder,
    }, fn roundIndex, acc ->

      # During the first half of each round, each Elf considers the eight positions
      # adjacent to themself. If no other Elves are in one of those eight positions, 
      # the Elf does not do anything during this round. Otherwise, the Elf looks in 
      # each of four directions in the following order and proposes moving one step 
      # in the first valid direction

      map = acc[:map]
      stepOrder = acc[:stepOrder]

      proposedMoves = Enum.reduce(0..(Enum.count(map) - 1), [], fn rowIndex, rowAcc ->
        rowMoves = Enum.reduce(0..(Enum.count(Enum.at(map, 0)) - 1), [], fn colIndex, colAcc ->
          case Enum.at(Enum.at(map, rowIndex), colIndex) do
            "#" ->
              
              IO.inspect("Elf at #{rowIndex}, #{colIndex} is proposing moves")

              #look at 8 adjacent positions
              adjacentSpaces = [
                Enum.at(Enum.at(map, rowIndex - 1), colIndex - 1),
                Enum.at(Enum.at(map, rowIndex - 1), colIndex),
                Enum.at(Enum.at(map, rowIndex - 1), colIndex + 1),
                Enum.at(Enum.at(map, rowIndex), colIndex - 1),
                Enum.at(Enum.at(map, rowIndex), colIndex + 1),
                Enum.at(Enum.at(map, rowIndex + 1), colIndex - 1),
                Enum.at(Enum.at(map, rowIndex + 1), colIndex),
                Enum.at(Enum.at(map, rowIndex + 1), colIndex + 1),
              ]

              if Enum.any?(adjacentSpaces, fn x -> x == "#" end) do
                proposedStep = Enum.reduce_while(stepOrder, {{colIndex, rowIndex}}, fn step, stepAcc ->
                  case step do
                    :north ->
                      considerPoints = [
                        Enum.at(Enum.at(map, rowIndex - 1), colIndex - 1),
                        Enum.at(Enum.at(map, rowIndex - 1), colIndex),
                        Enum.at(Enum.at(map, rowIndex - 1), colIndex + 1),
                      ]
                      if (Enum.any?(considerPoints, fn x -> x == "#" end)) do
                        {:cont, {colIndex, rowIndex}}
                      else
                        {:halt, {colIndex, rowIndex - 1}}
                      end
                    :south ->
                      considerPoints = [
                        Enum.at(Enum.at(map, rowIndex + 1), colIndex - 1),
                        Enum.at(Enum.at(map, rowIndex + 1), colIndex),
                        Enum.at(Enum.at(map, rowIndex + 1), colIndex + 1),
                      ]
                      if (Enum.any?(considerPoints, fn x -> x == "#" end)) do
                        {:cont, {colIndex, rowIndex}}
                      else
                        {:halt, {colIndex, rowIndex + 1}}
                      end
                    :west ->
                      considerPoints = [
                        Enum.at(Enum.at(map, rowIndex - 1), colIndex - 1),
                        Enum.at(Enum.at(map, rowIndex), colIndex - 1),
                        Enum.at(Enum.at(map, rowIndex + 1), colIndex - 1),
                      ]
                      if (Enum.any?(considerPoints, fn x -> x == "#" end)) do
                        {:cont, {colIndex, rowIndex}}
                      else
                        {:halt, {colIndex - 1, rowIndex}}
                      end
                    :east ->
                      considerPoints = [
                        Enum.at(Enum.at(map, rowIndex - 1), colIndex + 1),
                        Enum.at(Enum.at(map, rowIndex), colIndex + 1),
                        Enum.at(Enum.at(map, rowIndex + 1), colIndex + 1),
                      ]
                      if (Enum.any?(considerPoints, fn x -> x == "#" end)) do
                        {:cont, {colIndex, rowIndex}}
                      else
                        {:halt, {colIndex + 1, rowIndex}}
                      end
                  end
                end)

                IO.inspect("Elf at #{rowIndex}, #{colIndex} is proposing")
                IO.inspect(proposedStep)
                if proposedStep == {colIndex, rowIndex} do
                  colAcc
                else
                  colAcc ++ [%{from: {colIndex, rowIndex}, to: proposedStep}]
                end
              else
                colAcc
              end
            "." ->
              # Empty
              colAcc
          end
        end)

        rowAcc ++ rowMoves
      end)
      
      IO.inspect("proposed moves")
      IO.inspect(proposedMoves)
      
      # After each Elf has had a chance to propose a move, the second half of the 
      # round can begin. Simultaneously, each Elf moves to their proposed destination
      # tile if they were the only Elf to propose moving to that position. If two or 
      # more Elves propose moving to the same position, none of those Elves move.

      newMap = Enum.reduce(proposedMoves, map, fn move, mapAcc ->
        from = move[:from]
        to = move[:to]

        # check if any other elf is proposing to move to this space
        if Enum.any?(proposedMoves, fn x -> x[:to] == to and x[:from] != from end) do
          # don't move
          mapAcc
        else
          # move
          move_elf_from_to(mapAcc, from, to)
        end
      end)

      IO.inspect("movies applied")
      visualize_map(newMap)


      # Finally, at the end of the round, the first direction the Elves considered
      # is moved to the end of the list of directions. For example, during the 
      # second round, the Elves would try proposing a move to the south first, then
      # west, then east, then north. On the third round, the Elves would first 
      # consider west, then east, then north, then south.

      newStepOrder = Enum.drop(stepOrder, 1) ++ [Enum.at(stepOrder, 0)]

      %{
        map: newMap,
        stepOrder: newStepOrder
      }    
    
    end)
    
    IO.inspect("final map")
    visualize_map(result[:map])

    # identify the smallest rectangle that contains all the elves
    # count the number of spaces in that rectangle

    allElvesCoords = Enum.reduce(0..length(result[:map]) - 1, [], fn rowIndex, rowAcc ->
      rowAcc ++ Enum.reduce(0..length(Enum.at(result[:map], rowIndex)) - 1, [], fn colIndex, colAcc ->
        case Enum.at(Enum.at(result[:map], rowIndex), colIndex) do
          "#" ->
            colAcc ++ [{colIndex, rowIndex}]
          "." ->
            colAcc
        end
      end)
    end)

    IO.inspect("allElvesCoords")
    IO.inspect(allElvesCoords)

    northernMostY = Enum.min_by(allElvesCoords, fn x -> x |> elem(1) end) |> elem(1)
    southernMostY = Enum.max_by(allElvesCoords, fn x -> x |> elem(1) end) |> elem(1)

    westernMostX = Enum.min_by(allElvesCoords, fn x -> x |> elem(0) end) |> elem(0)
    easternMostX = Enum.max_by(allElvesCoords, fn x -> x |> elem(0) end) |> elem(0)

    IO.inspect("northernMostY: #{northernMostY}")
    IO.inspect("southernMostY: #{southernMostY}")
    IO.inspect("westernMostX: #{westernMostX}")
    IO.inspect("easternMostX: #{easternMostX}")

    emptySpacesInBounds = Enum.reduce(northernMostY..southernMostY, 0, fn rowIndex, rowAcc ->
      rowAcc + Enum.reduce(westernMostX..easternMostX, 0, fn colIndex, colAcc ->
        case Enum.at(Enum.at(result[:map], rowIndex), colIndex) do
          "#" ->
            colAcc
          "." ->
            colAcc + 1
        end
      end)
    end)


  end
end

IO.inspect(Day23.main())
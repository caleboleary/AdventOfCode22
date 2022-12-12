defmodule Day12 do
  def get_input do
    # File.read!("./day12/day12testinput.txt")
    File.read!("./day12/day12input.txt")
  end

  def indexOf(string, substr) do
      split = String.split(string, substr)
      if length(split) == 1 do
          -1
      else
          String.length(split |> List.first) + 1
      end
  end

  def alphabet do "abcdefghijklmnopqrstuvwxyz" end

  def get_possible_moves(position, matrixInput) do 

    # get all possible moves from lastMove
      possibleMoves = [
        [Enum.at(position, 0) + 1, Enum.at(position, 1)],
        [Enum.at(position, 0) - 1, Enum.at(position, 1)],
        [Enum.at(position, 0), Enum.at(position, 1) + 1],
        [Enum.at(position, 0), Enum.at(position, 1) - 1]
      ]

      # filter out moves that are out of bounds
      possibleMovesOOB = Enum.filter(possibleMoves, fn move ->
        Enum.at(move, 0) >= 0 and Enum.at(move, 0) < (Enum.at(matrixInput, 0) |> Enum.count()) and Enum.at(move, 1) >= 0 and Enum.at(move, 1) < (matrixInput |> Enum.count())
      end)

      currPosHeight = indexOf(alphabet(), Enum.at(Enum.at(matrixInput, Enum.at(position, 1)), Enum.at(position, 0)))

      # filter out moves that are too much change in elevation
      possibleMovesElev = Enum.filter(possibleMovesOOB, fn move ->
        indexOf(alphabet(), Enum.at(Enum.at(matrixInput, Enum.at(move, 1)), Enum.at(move, 0))) <= currPosHeight + 1
      end)

  end

  def main do
    rawInput = get_input()

    startStringIndex = indexOf(String.replace(rawInput, "\n", ""), "S") - 1

    endStringIndex = indexOf(String.replace(rawInput, "\n", ""), "E") - 1

    matrixInput = String.split(
      rawInput |> String.replace("S", "a") |> String.replace("E", "z"),
      "\n",
      trim: true
    ) |> Enum.map(fn x -> String.split(x, "", trim: true) end)

    startCoords = [
      rem(startStringIndex,  (Enum.at(matrixInput, 0) |> Enum.count())),
      trunc(startStringIndex / (Enum.at(matrixInput, 0) |> Enum.count()))
    ]

    endCoords = [
      rem(endStringIndex,  (Enum.at(matrixInput, 0) |> Enum.count())),
      trunc(endStringIndex / (Enum.at(matrixInput, 0) |> Enum.count()))
    ]

    priorityQueue = Enum.reduce(0..length(matrixInput), %{}, fn row, acc ->
      Enum.reduce(0..length(Enum.at(matrixInput, 0)), acc, fn col, acc2 ->
        acc2
          |> Map.put(
            "#{col}-#{row}",
            if [col, row] == startCoords do 0 else :infinity end
          )
      end)
    end) 
    |> Enum.sort(fn {_, a}, {_, b} -> a < b end)

    Enum.reduce_while(1..20000, %{priorityQueue: priorityQueue, visitedNodes: []}, fn iteration, acc ->

      #get the shortest path that hasn't been visited yet
      {topOfQueue, topDist} = Enum.find(acc.priorityQueue, fn {key, _} -> not Enum.member?(acc.visitedNodes, 
        String.split(key, "-", trim: true) |> Enum.map(fn x -> String.to_integer(x) end)
      ) end)
      
      #grab the shortest path
      currentNode = String.split(topOfQueue, "-", trim: true) |> Enum.map(fn x -> String.to_integer(x) end)

      viableNeighbors = get_possible_moves(currentNode, matrixInput)

      newAcc = %{
          priorityQueue: Enum.reduce(viableNeighbors, acc.priorityQueue, fn neighbor, acc2 ->
          neighborKey = "#{Enum.at(neighbor, 0)}-#{Enum.at(neighbor, 1)}"
          neighborDist = Enum.find(acc.priorityQueue, fn {key, _} -> key == neighborKey end) |> elem(1)

          if neighborDist === :infinity or neighborDist > topDist + 1 do
            filteredAcc2 = acc2 |> Enum.filter(fn {key, _} -> key != neighborKey end)
            newEntry = {"#{neighborKey}", topDist + 1}
            filteredAcc2 ++ [newEntry]
          else
            acc2
          end
        end)
        #sort by second element of tuple ascending
        |> Enum.sort(fn {_, a}, {_, b} -> a < b end),
        visitedNodes: [currentNode | acc.visitedNodes]
      }

      #if end coords dist is not infinity, we're done
      if Enum.find(newAcc.priorityQueue, fn {key, _} -> key == "#{Enum.at(endCoords, 0)}-#{Enum.at(endCoords, 1)}" end) |> elem(1) != :infinity do
        IO.inspect("done")
        IO.inspect(newAcc)
        IO.inspect(Enum.find(newAcc.priorityQueue, fn {key, _} -> key == "#{Enum.at(endCoords, 0)}-#{Enum.at(endCoords, 1)}" end) |> elem(1))
        {:halt, newAcc}
      else
        {:cont, newAcc}
      end

      # throw "test"

    end)

  end
end

Day12.main()
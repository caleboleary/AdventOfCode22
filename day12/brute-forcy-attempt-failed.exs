defmodule Day12 do
  def get_input do
    # File.read!("./day12/day12testinput.txt")
    File.read!("./day12/day12input.txt")
        # |> String.split("\n", trim: true)
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

  def get_possible_moves(position, moveChain, matrixInput) do 

    # IO.inspect("get possible moves invoked")
    # IO.inspect(position)
    # IO.inspect(moveChain)
    # IO.inspect(matrixInput)

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
      # possibleMovesElev = Enum.filter(possibleMovesOOB, fn move ->
      #   indexOf(alphabet(), Enum.at(Enum.at(matrixInput, Enum.at(move, 1)), Enum.at(move, 0))) >= (currPosHeight - 1)
      # end)


      # filter out moves that are already in moveChain
      possibleMovesHist = Enum.filter(possibleMovesElev, fn move ->
        not Enum.member?(moveChain, move)
      end)

      # append each possible move to moveChain
      possibleMoveChains = Enum.map(possibleMovesHist, fn move ->
        moveChain ++ [move]
      end)

      # IO.inspect(possibleMoveChains)
  end

  def distance([ax, ay], [bx, by]) do
    abs(ax - bx) + abs(ay - by)
  end

  def main do
    rawInput = get_input()

    startStringIndex = indexOf(String.replace(rawInput, "\n", ""), "S") - 1
    # startStringIndex = indexOf(String.replace(rawInput, "\n", ""), "E") - 1

    endStringIndex = indexOf(String.replace(rawInput, "\n", ""), "E") - 1
    # endStringIndex = indexOf(String.replace(rawInput, "\n", ""), "S") - 1

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

    # IO.inspect(startCoords)
    # IO.inspect(endCoords)

    #let's limit to 10k iterations for now...
    Enum.reduce_while(1..20000, [[startCoords]], fn iteration, acc ->

      # shape of acc:
      # [
      #   [[0,0], [0,1]],
      #   [[0,0], [1,0]],
      #   ...
      # ]

      
      # for each move chain in acc, get all possible moves
      newMoveSets = Enum.flat_map(acc, fn moveChain ->
        # shape of moveChain:
        # [[0,0], [0,1], ...]

        # get last move in moveChain
        lastMove = Enum.at(moveChain, -1)

        get_possible_moves(lastMove, moveChain, matrixInput)
      end)

      # IO.inspect("after our map to get all moves for all chains")
      # IO.inspect(newMoveSets)

      #fl
      newAcc = newMoveSets

      # filter to the 1000000 move chains with the lowest distance to endCoords using the distance function
      filteredNewAcc = newAcc
        |> Enum.sort_by(fn x -> distance(Enum.at(x, -1), endCoords) end)
        |> Enum.take(1000000)

      IO.inspect("--------------------")
      IO.inspect(iteration)
      IO.inspect(length(filteredNewAcc))
      IO.inspect("--------------------")

      if (length(filteredNewAcc) == 0) do
        IO.inspect("no solution found")
        IO.inspect(iteration)
        IO.inspect("no solution found")
        throw "no solution found"
      end


      # IO.inspect("after our flatten")
      # IO.inspect(acc)
      # IO.inspect(newAcc)

      solution = Enum.find(filteredNewAcc, fn x -> Enum.at(x, -1) == endCoords end)
     

      # if any move chain in acc ends in endCoords, return iteration
      if (solution != nil) do
        IO.inspect("solution found")
        IO.inspect(filteredNewAcc)
        IO.inspect(solution)
        IO.inspect(iteration)
        IO.inspect("solution found")
        {:halt, solution}
      else
        # else, add all possible moves to acc
        {:cont, filteredNewAcc}
      end

    end)
    

  end
end

Day12.main()
defmodule Day24 do
  def get_input do
    # File.read!("./day24/day24simpleinput.txt")
    # File.read!("./day24/day24testinput.txt")
    File.read!("./day24/day24input.txt")
        |> String.split("\n", trim: true)
        |> Enum.map(fn x -> String.split(x, "", trim: true) end)
  end

  def visualize_map(map, playerCoords) do
    IO.inspect("---------------------------")
    
    Enum.with_index(map) |> Enum.each(fn {row, rowIndex} ->
      rowStr = Enum.with_index(row) |> Enum.map(fn {cell, cellIndex} ->
        if {cellIndex, rowIndex} == playerCoords do
          "E"
        else
          cell
        end
      end) |> Enum.join("")
      IO.inspect(rowStr)
    end)

    IO.inspect("---------------------------")
  end

  def visualize_map(map) do
    IO.inspect("---------------------------")
    
    map |> Enum.map(fn x -> x |> Enum.join() |> IO.inspect() end)

    IO.inspect("---------------------------")
  end

  def parse_input(input) do
    blizzards = input |> Enum.with_index() |> Enum.flat_map(fn {row, i} -> 
      Enum.with_index(row) |> Enum.map(fn {cell, j} -> 
        case cell do
          ">" -> %{
            x: j,
            y: i,
            direction: :right,
          }
          "<" -> %{
            x: j,
            y: i,
            direction: :left,
          }
          "^" -> %{
            x: j,
            y: i,
            direction: :up,
          }
          "v" -> %{
            x: j,
            y: i,
            direction: :down,
          }
          "." -> nil
          "#" -> nil
        end
      end)
    end)
    |> Enum.filter(fn x -> x !== nil end)

    startX = Enum.at(input, 0) |> Enum.find_index(fn x -> x == "." end)

    endX = Enum.at(input, length(input) - 1) |> Enum.find_index(fn x -> x == "." end)

    %{
      blizzards: blizzards,
      start: {startX, 0},
      end: {endX, length(input) - 1},
      height: length(input),
      width: length(Enum.at(input, 0)),
    }
  end

  def get_gamestate_at_turn_index(startState, turnIndex) do
    blizzCoords = Enum.map(startState.blizzards, fn blizz ->

      case blizz.direction do
        :right -> 
          %{
            symbol: ">",
            coords: {
              rem((blizz.x - 1) + turnIndex, startState.width - 2) + 1,
              blizz.y,
            }
          }
        :left ->
          distFromRight = rem(turnIndex + ((startState.width - 2) - blizz.x), startState.width - 2)
          %{
            symbol: "<",
            coords: {
              (startState.width - 2) - distFromRight,
              blizz.y,
            }
          }
        :up ->
          distFromBottom = rem(turnIndex + ((startState.height - 2) - blizz.y), startState.height - 2)
          %{
            symbol: "^",
            coords: {
              blizz.x,
              (startState.height - 2) - distFromBottom,
            }
          }
        :down ->
          %{
            symbol: "v",
            coords: {
              blizz.x,
              rem((blizz.y - 1) + turnIndex, startState.height - 2) + 1,
            }
          }
      end
    end)

    Enum.map(0..startState.height - 1, fn y ->
      Enum.map(0..startState.width - 1, fn x ->
        if x == 0 or x == startState.width - 1 or y == 0 or y == startState.height - 1 do
          if {x, y} == startState.start or {x, y} == startState.end do
            "."
          else
            "#"
          end
        else
          filtered = Enum.filter(blizzCoords, fn blizz -> blizz.coords == {x, y} end)
          if length(filtered) > 0 do
            if length(filtered) > 1 do
              "#{length(filtered)}"
            else
              Enum.at(filtered, 0).symbol
            end
          else
            "."
          end
        end
      end)
    end)

  end

  def get_possible_moves({currX, currY}, nextTurnMap) do
    #possible moves, up, down, left, right, stay
    allPossibleMoves = [
      {currX, currY - 1},
      {currX, currY + 1},
      {currX - 1, currY},
      {currX + 1, currY},
      {currX, currY},
    ]

    Enum.filter(allPossibleMoves, fn {x, y} ->
      if x < 0 or y < 0 or x >= length(Enum.at(nextTurnMap, 0)) or y >= length(nextTurnMap) do
        false
      else
        cond do
          Enum.at(Enum.at(nextTurnMap, y), x) == "." -> true
          true -> false
        end
      end
    end)
  end

  def main do
    input = get_input()
    
    visualize_map(input)

    startState = parse_input(input)

    shortestValidPath = Enum.reduce_while(0..10000, [[startState.start]], fn turnIndex, moveChainAcc ->
      IO.inspect("breadth: #{length(moveChainAcc)}")
      nextTurnMap = get_gamestate_at_turn_index(startState, turnIndex + 1)

      possibleMoveChains = Enum.flat_map(moveChainAcc, fn moveChain ->
        possibleMoves = get_possible_moves(Enum.at(moveChain, length(moveChain) - 1), nextTurnMap)

        Enum.map(possibleMoves, fn move ->
          moveChain ++ [move]
        end)
      end)

      #if any move chains end at startState.end, halt and return that move chain
      filtered = Enum.filter(possibleMoveChains, fn moveChain ->
        Enum.at(moveChain, length(moveChain) - 1) == startState.end
      end)

      if (length(filtered) > 0) do
        IO.inspect("valid paths found: #{length(filtered)}")
      end

      if length(filtered) > 0 do
        {:halt, Enum.at(filtered, 0)}
      else
        {:cont, Enum.uniq_by(possibleMoveChains, fn moveChain -> Enum.at(moveChain, turnIndex + 1) end)}
      end

    end)

    IO.inspect("path found")
    # IO.inspect(shortestValidPath, limit: :infinity)
    # Enum.with_index(shortestValidPath) |> Enum.map(fn {{x, y}, i} -> visualize_map(get_gamestate_at_turn_index(startState, i), {x,y}) end)
    IO.inspect(length(shortestValidPath) - 1)

  end
end

IO.inspect(Day24.main())
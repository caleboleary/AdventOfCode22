defmodule Day9 do
  def get_input do
    # File.read!("./day9/day9testinput.txt")
    File.read!("./day9/day9input.txt")
        |> String.split("\n", trim: true)
  end

  def update_h_pos(oldPos, dir) do
    case dir do
      "U" -> [Enum.at(oldPos, 0), Enum.at(oldPos, 1) + 1]
      "D" -> [Enum.at(oldPos, 0), Enum.at(oldPos, 1) - 1]
      "L" -> [Enum.at(oldPos, 0) - 1, Enum.at(oldPos, 1)]
      "R" -> [Enum.at(oldPos, 0) + 1, Enum.at(oldPos, 1)]
    end
  end

  def update_t_pos(oldPos, hPos) do
    #t follows h, but not always straightforward
    #t can happily inhabit the same coord as h.
    #t wants to stay touching h, is happy to touch diagonally 
    #but if t moves to a new coord, it wants to stay touching h orthogonally

    verticalDiff = Enum.at(hPos, 1) - Enum.at(oldPos, 1)
    horizontalDiff = Enum.at(hPos, 0) - Enum.at(oldPos, 0)

    cond do
        #touching cases - t stays put
        verticalDiff == 0 and horizontalDiff == 0 -> oldPos
        verticalDiff == 0 and horizontalDiff == 1 -> oldPos
        verticalDiff == 0 and horizontalDiff == -1 -> oldPos
        verticalDiff == 1 and horizontalDiff == 0 -> oldPos
        verticalDiff == -1 and horizontalDiff == 0 -> oldPos
        verticalDiff == 1 and horizontalDiff == 1 -> oldPos
        verticalDiff == 1 and horizontalDiff == -1 -> oldPos
        verticalDiff == -1 and horizontalDiff == 1 -> oldPos
        verticalDiff == -1 and horizontalDiff == -1 -> oldPos
        #otherwise, t moves to be orthogonally touching h
        verticalDiff == 0 and horizontalDiff == 2 -> [Enum.at(oldPos, 0) + 1, Enum.at(oldPos, 1)]
        verticalDiff == 0 and horizontalDiff == -2 -> [Enum.at(oldPos, 0) - 1, Enum.at(oldPos, 1)]
        verticalDiff == 2 and horizontalDiff == 0 -> [Enum.at(oldPos, 0), Enum.at(oldPos, 1) + 1]
        verticalDiff == -2 and horizontalDiff == 0 -> [Enum.at(oldPos, 0), Enum.at(oldPos, 1) - 1]
        verticalDiff == 2 and horizontalDiff == 1 -> [Enum.at(oldPos, 0) + 1, Enum.at(oldPos, 1) + 1]
        verticalDiff == 2 and horizontalDiff == -1 -> [Enum.at(oldPos, 0) - 1, Enum.at(oldPos, 1) + 1]
        verticalDiff == -2 and horizontalDiff == 1 -> [Enum.at(oldPos, 0) + 1, Enum.at(oldPos, 1) - 1]
        verticalDiff == -2 and horizontalDiff == -1 -> [Enum.at(oldPos, 0) - 1, Enum.at(oldPos, 1) - 1]
        verticalDiff == 1 and horizontalDiff == 2 -> [Enum.at(oldPos, 0) + 1, Enum.at(oldPos, 1) + 1]
        verticalDiff == 1 and horizontalDiff == -2 -> [Enum.at(oldPos, 0) - 1, Enum.at(oldPos, 1) + 1]
        verticalDiff == -1 and horizontalDiff == 2 -> [Enum.at(oldPos, 0) + 1, Enum.at(oldPos, 1) - 1]
        verticalDiff == -1 and horizontalDiff == -2 -> [Enum.at(oldPos, 0) - 1, Enum.at(oldPos, 1) - 1]
    end



  end

  def main do
    #wondering about a naive solution here... rather than creating the entire map, can I just store xy coords?

    #[x, y] notation
    input = get_input()
    |> Enum.reduce(%{hPos: [0,0], tPos: [0,0], allTPos: ["0-0"]}, fn movement, acc -> 
        [dir, amount] = String.split(movement, " ", trim: true)
        
        IO.inspect(movement)
        #loop amount times, updating the hpos each time
        positions = Enum.reduce(1..String.to_integer(amount), [%{hPos: acc.hPos, tPos: acc.tPos}], fn _, acc2 ->
            newHPos = update_h_pos(Enum.at(acc2, -1).hPos, dir)
            newTPos = update_t_pos(Enum.at(acc2, -1).tPos, newHPos)
            acc2 ++ [%{hPos: newHPos, tPos: newTPos}]
        end)

        IO.inspect(positions)

        %{
            hPos: Enum.at(positions, -1).hPos,
            tPos: Enum.at(positions, -1).tPos,
            allTPos: Enum.uniq(acc.allTPos ++ Enum.map(positions, fn pos -> "#{Enum.at(pos.tPos, 0)}-#{Enum.at(pos.tPos, 1)}" end))
        }
     end) 
  end
end

IO.inspect(Day9.main().allTPos |> Enum.count())






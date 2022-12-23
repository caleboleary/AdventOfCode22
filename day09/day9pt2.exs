defmodule Day9 do
  def get_input do
    # File.read!("./day9/day9testinput.txt")
    # File.read!("./day9/day9testinput2.txt")
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
        #in pt 2, it appears distances of 2 and 2 are possible, so we need to handle those cases
        verticalDiff == 2 and horizontalDiff == 2 -> [Enum.at(oldPos, 0) + 1, Enum.at(oldPos, 1) + 1]
        verticalDiff == 2 and horizontalDiff == -2 -> [Enum.at(oldPos, 0) - 1, Enum.at(oldPos, 1) + 1]
        verticalDiff == -2 and horizontalDiff == 2 -> [Enum.at(oldPos, 0) + 1, Enum.at(oldPos, 1) - 1]
        verticalDiff == -2 and horizontalDiff == -2 -> [Enum.at(oldPos, 0) - 1, Enum.at(oldPos, 1) - 1]

    end



  end

  def main do
    #wondering about a naive solution here... rather than creating the entire map, can I just store xy coords?

    #[x, y] notation
    input = get_input()
    |> Enum.reduce(
        %{
            hPos: [0,0], 
            k1Pos: [0,0], 
            k2Pos: [0,0], 
            k3Pos: [0,0], 
            k4Pos: [0,0], 
            k5Pos: [0,0], 
            k6Pos: [0,0], 
            k7Pos: [0,0], 
            k8Pos: [0,0], 
            tPos: [0,0], 
            allTPos: ["0-0"]
        }, fn movement, acc -> 
        [dir, amount] = String.split(movement, " ", trim: true)
        
        IO.inspect(movement)
        #loop amount times, updating the hpos each time
        positions = Enum.reduce(1..String.to_integer(amount), [
            %{
                hPos: acc.hPos, 
                k1Pos: acc.k1Pos, 
                k2Pos: acc.k2Pos, 
                k3Pos: acc.k3Pos, 
                k4Pos: acc.k4Pos, 
                k5Pos: acc.k5Pos, 
                k6Pos: acc.k6Pos, 
                k7Pos: acc.k7Pos, 
                k8Pos: acc.k8Pos, 
                tPos: acc.tPos
            }
        ], fn _, acc2 ->
            IO.inspect("newHPos")
            newHPos = update_h_pos(Enum.at(acc2, -1).hPos, dir)
            IO.inspect("newK1Pos")
            newK1Pos = update_t_pos(Enum.at(acc2, -1).k1Pos, newHPos)
            IO.inspect("newK2Pos")
            newK2Pos = update_t_pos(Enum.at(acc2, -1).k2Pos, newK1Pos)
            IO.inspect("newK3Pos")
            newK3Pos = update_t_pos(Enum.at(acc2, -1).k3Pos, newK2Pos)
            IO.inspect("newK4Pos")
            newK4Pos = update_t_pos(Enum.at(acc2, -1).k4Pos, newK3Pos)
            IO.inspect("newK5Pos")
            IO.inspect(Enum.at(acc2, -1).k5Pos)
            IO.inspect(newK4Pos)
            newK5Pos = update_t_pos(Enum.at(acc2, -1).k5Pos, newK4Pos)
            IO.inspect("newK6Pos")
            newK6Pos = update_t_pos(Enum.at(acc2, -1).k6Pos, newK5Pos)
            IO.inspect("newK7Pos")
            newK7Pos = update_t_pos(Enum.at(acc2, -1).k7Pos, newK6Pos)
            IO.inspect("newK8Pos")
            newK8Pos = update_t_pos(Enum.at(acc2, -1).k8Pos, newK7Pos)
            IO.inspect("newTPos")
            newTPos = update_t_pos(Enum.at(acc2, -1).tPos, newK8Pos)
            acc2 ++ [
                %{
                    hPos: newHPos, 
                    k1Pos: newK1Pos,
                    k2Pos: newK2Pos,
                    k3Pos: newK3Pos,
                    k4Pos: newK4Pos,
                    k5Pos: newK5Pos,
                    k6Pos: newK6Pos,
                    k7Pos: newK7Pos,
                    k8Pos: newK8Pos,
                    tPos: newTPos
                }
            ]
        end)

        IO.inspect(positions)

        %{
            hPos: Enum.at(positions, -1).hPos,
            k1Pos: Enum.at(positions, -1).k1Pos,
            k2Pos: Enum.at(positions, -1).k2Pos,
            k3Pos: Enum.at(positions, -1).k3Pos,
            k4Pos: Enum.at(positions, -1).k4Pos,
            k5Pos: Enum.at(positions, -1).k5Pos,
            k6Pos: Enum.at(positions, -1).k6Pos,
            k7Pos: Enum.at(positions, -1).k7Pos,
            k8Pos: Enum.at(positions, -1).k8Pos,
            tPos: Enum.at(positions, -1).tPos,
            allTPos: Enum.uniq(acc.allTPos ++ Enum.map(positions, fn pos -> "#{Enum.at(pos.tPos, 0)}-#{Enum.at(pos.tPos, 1)}" end))
        }
     end) 
  end
end

IO.inspect(Day9.main().allTPos |> Enum.count())






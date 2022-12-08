defmodule Day8 do
  def get_input do
    # File.read!("./day8/day8testinput.txt")
    File.read!("./day8/day8input.txt")
  end

  def get_scenic_score(treeHeight, row) do

    score = Enum.reduce_while(row, 0, fn currentRowTreeHeight, acc ->

      if (currentRowTreeHeight >= treeHeight) do
        {:halt, acc + 1}
      else
        {:cont, acc + 1}
      end

    end)

  end

  def derive_visible_map(treeMap, visibleMap) do
    visibleMap
        |> Enum.with_index
        |> Enum.reduce(visibleMap, fn {_, i}, acc->
            row = Enum.at(treeMap, i)

            newChartMapRow = row
                |> Enum.with_index
                |> Enum.reduce(Enum.at(acc, i), fn {_, j}, rowAcc ->
                    treeHeight = Enum.at(row, j);

                    # #look left
                    leftScenicScore = get_scenic_score(treeHeight, Enum.slice(row, 0, j) |> Enum.reverse)

                    # #look right
                    rightScenicScore = get_scenic_score(treeHeight, Enum.slice(row, j + 1, length(row)))

                    # #look up
                    upScenicScore = get_scenic_score(treeHeight, Enum.slice(treeMap, 0, i) |> Enum.map(fn x -> Enum.at(x, j) end) |> Enum.reverse)

                    # #look down
                    downScenicScore = get_scenic_score(treeHeight, Enum.slice(treeMap, i + 1, length(treeMap)) |> Enum.map(fn x -> Enum.at(x, j) end))

                    scenicScore = leftScenicScore * rightScenicScore * upScenicScore * downScenicScore

                    if scenicScore > 0 do
                        Enum.slice(rowAcc, 0, j) ++ [scenicScore] ++ Enum.slice(rowAcc, j + 1, length(rowAcc))
                    else
                        rowAcc
                    end

                    # if isEdge or isVisibleLeft or isVisibleRight or isVisibleUp or isVisibleDown do
                    #     Enum.slice(rowAcc, 0, j) ++ [1] ++ Enum.slice(rowAcc, j + 1, length(rowAcc))
                    # else
                    #     rowAcc
                    # end
                    
                end)
            
            
            Enum.slice(acc, 0, i) ++ [newChartMapRow] ++ Enum.slice(acc, i + 1, length(acc))
            
        end)
  end


  def main do
    input = get_input()
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> String.split(x, "", trim: true) end)
    |> Enum.map(fn x -> Enum.map(x, fn y -> String.to_integer(y) end) end)

    falseRow = Enum.at(input, 0) |> Enum.map(fn x -> 0 end)
    visibleChart = Enum.map(input, fn _ -> falseRow end)

    visibleMap = derive_visible_map(input, visibleChart)

    IO.inspect(visibleMap)

    visibleMap
        |> Enum.map(fn x -> Enum.max(x) end)
        |> Enum.max()

   
  end
end

IO.inspect(Day8.main())






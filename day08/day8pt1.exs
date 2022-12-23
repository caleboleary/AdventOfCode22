defmodule Day8 do
  def get_input do
    # File.read!("./day8/day8testinput.txt")
    File.read!("./day8/day8input.txt")
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

                    isEdge = (i === 0 or i === length(treeMap) - 1) or (j === 0 or j === length(row) - 1)

                    #look left
                    isVisibleLeft = Enum.slice(row, 0, j) |> Enum.all?(& &1 < treeHeight)

                    #look right
                    isVisibleRight = Enum.slice(row, j + 1, length(row)) |> Enum.all?(& &1 < treeHeight)

                    #look up
                    isVisibleUp = Enum.slice(treeMap, 0, i) 
                    |> Enum.map(fn x -> Enum.at(x, j) end)
                    |> Enum.all?(& &1 < treeHeight)

                    #look down
                    isVisibleDown = Enum.slice(treeMap, i + 1, length(treeMap))
                    |> Enum.map(fn x -> Enum.at(x, j) end)
                    |> Enum.all?(& &1 < treeHeight)

                    if isEdge or isVisibleLeft or isVisibleRight or isVisibleUp or isVisibleDown do
                        Enum.slice(rowAcc, 0, j) ++ [1] ++ Enum.slice(rowAcc, j + 1, length(rowAcc))
                    else
                        rowAcc
                    end
                    
                end)
            
            
            Enum.slice(acc, 0, i) ++ [newChartMapRow] ++ Enum.slice(acc, i + 1, length(acc))
            
        end)
  end


  def main do
    input = get_input()
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> String.split(x, "", trim: true) end)

    falseRow = Enum.at(input, 0) |> Enum.map(fn x -> 0 end)
    visibleChart = Enum.map(input, fn _ -> falseRow end)

    visibleMap = derive_visible_map(input, visibleChart)

    IO.inspect(visibleMap)

    visibleMap
        |> Enum.map(fn row ->
            row
                |> Enum.map(fn x ->
                    x
                end)
                |> Enum.join("")
        end)
        |> Enum.join("") |> String.graphemes |> Enum.count(& &1 == "1")

   
  end
end

IO.inspect(Day8.main())






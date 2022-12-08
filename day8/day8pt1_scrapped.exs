defmodule Day8 do
  def get_input do
    File.read!("./day8/day8testinput.txt")
    # File.read!("./day8/day8input.txt")
  end

  def derive_visible_left_and_up(treeMap, visibleMap) do
    visibleMap
        |> Enum.with_index
        |> Enum.reduce(visibleMap, fn {_, i}, acc->
            row = Enum.at(treeMap, i)

            IO.inspect(row)


            newChartMapRow = row
                |> Enum.with_index
                |> Enum.reduce(Enum.at(acc, i), fn {_, j}, rowAcc ->
                    treeHeight = Enum.at(row, j);

                    isAlreadyVisible = Enum.at(rowAcc, j) === 1

                    isEdge = (i === 0 or i === length(treeMap) - 1) or (j === 0 or j === length(row) - 1)

                    #look up
                    isVisibleUp = (Enum.at(Enum.at(acc, i - 1), j) === 1 && treeHeight > Enum.at(Enum.at(treeMap, i - 1), j))


                    #look left
                    isVisibleLeft = (Enum.at(rowAcc, j - 1) === 1 && treeHeight > Enum.at(Enum.at(treeMap, i), j - 1))

                    if isAlreadyVisible or isEdge or isVisibleUp or isVisibleLeft do
                        Enum.slice(rowAcc, 0, j) ++ [1] ++ Enum.slice(rowAcc, j + 1, length(rowAcc))
                    else
                        rowAcc
                    end
                    
                end)
            
            IO.inspect(newChartMapRow)
            
            Enum.slice(acc, 0, i) ++ [newChartMapRow] ++ Enum.slice(acc, i + 1, length(acc))
            
        end)
  end

  def reverse_matrix(matrix) do
    matrix
        |> Enum.map(fn row ->
            row
                |> Enum.reverse
        end)
        |> Enum.reverse
  end

  def main do
    input = get_input()
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> String.split(x, "", trim: true) end)

    falseRow = Enum.at(input, 0) |> Enum.map(fn x -> 0 end)
    visibleChart = Enum.map(input, fn _ -> falseRow end)

    IO.inspect(visibleChart)

    firstPass = derive_visible_left_and_up(input, visibleChart)

    secondPass = derive_visible_left_and_up(reverse_matrix(input), reverse_matrix(firstPass))

    IO.inspect(reverse_matrix(secondPass))
    IO.inspect(input)

    #join the matrix into one string
    secondPass
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






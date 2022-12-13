defmodule Day13 do
  def get_input do
    # File.read!("./day13/day13testinput2.txt")
    # File.read!("./day13/day13testinput.txt")
    File.read!("./day13/day13input.txt")
        |> String.replace("\n\n", "\n")
        |> String.split("\n", trim: true)
  end

  def comPair(a, b) do

  
    indexed = Enum.with_index(a)


    test = Enum.reduce_while(indexed, 0, fn {leftComparator, index}, acc ->
      rightComparator = Enum.at(b, index)

      cond do 
        rightComparator |> is_list() and leftComparator |> is_list() ->
          result = comPair(leftComparator, rightComparator)
          if result === 0 do
            {:cont, 0}
          else
            {:halt, result}
          end
        rightComparator |> is_list() and leftComparator |> is_integer() ->
          result = comPair([leftComparator], rightComparator)
          if result === 0 do
            {:cont, 0}
          else
            {:halt, result}
          end
        leftComparator |> is_list() and rightComparator |> is_integer() ->
          result = comPair(leftComparator, [rightComparator])
          if result === 0 do
            {:cont, 0}
          else
            {:halt, result}
          end
        leftComparator |> is_integer() and rightComparator |> is_integer() ->
          cond do
            rightComparator === nil ->
              {:halt, -1}
            leftComparator === rightComparator ->
              {:cont, 0}
            leftComparator < rightComparator ->
              {:halt, 1}
            leftComparator > rightComparator ->
              {:halt, -1}
          end
        leftComparator === nil and rightComparator === nil ->
          {:halt, 0}
        leftComparator === nil ->
          {:halt, 1}
        rightComparator === nil ->
          {:halt, -1}
        true ->
          {:halt, -1}
      end      
      
    end)

    if (length(a) < length(b) and test === 0) do
      test = 1
    else
      test
    end

  end


  def main do
    input = get_input()

    inputWithMarkers = input ++ ["[[2]]", "[[6]]"]

    lines = Enum.map(inputWithMarkers, fn x ->
      x
        |> Code.eval_string()
        |> elem(0)
    end)
      |> IO.inspect(limit: :infinity)


    sorted = Enum.sort(
      lines,
      fn a, b ->
        res = comPair(a, b)
        cond do
          res === 0 ->
            false
          res === 1 ->
            false
          res === -1 ->
            true
        end
      end
    )
    |> Enum.reverse()

    marker1Index = Enum.find_index(sorted, fn x -> x === [[2]] end) + 1
    marker2Index = Enum.find_index(sorted, fn x -> x === [[6]] end) + 1

    marker1Index * marker2Index


  end
end

IO.inspect(Day13.main(), charlists: :as_lists)
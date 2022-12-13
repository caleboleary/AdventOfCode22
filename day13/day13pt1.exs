defmodule Day13 do
  def get_input do
    # File.read!("./day13/day13testinput2.txt")
    # File.read!("./day13/day13testinput.txt")
    File.read!("./day13/day13input.txt")
        |> String.split("\n\n", trim: true)
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

    pairs = Enum.map(input, fn x ->
      x
      |> String.split("\n", trim: true)
      |> Enum.map(fn y ->
        y
        |> Code.eval_string()
        |> elem(0)
      end)
    end)

    pairs
      # |> Enum.slice(0, 4)
      |> Enum.map(fn pair ->
        [a, b] = pair
        comPair(a, b)
      end)
      |> Enum.join(",")
      |> IO.inspect(charlists: :as_lists)
      |> String.split(",")
      |> Enum.map(fn x -> String.to_integer(x) end)
      |> Enum.with_index()
      |> Enum.filter(fn {x,i} -> x !== -1 end)
      |> Enum.map(fn {x,i} -> i+1 end)
      |> IO.inspect(limit: :infinity)
      |> Enum.reduce(0, fn x, acc -> acc + x end)


    
    

  end
end

IO.inspect(Day13.main(), charlists: :as_lists)
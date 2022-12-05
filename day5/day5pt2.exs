defmodule Day5 do
  def get_input do
    File.read!("./day5/day5input.txt")
  end

  def parse_input(inputStr) do
    split = String.split(inputStr, "\n\n", trim: true)
    stacks = Enum.at(split, 0)
    steps = Enum.at(split, 1) |> String.split("\n", trim: true)

    numCols = String.split(stacks, "\n", trim: true) 
      |> Enum.at(-1) 
      |> String.replace(~r"[\s]", "") 
      |> String.length()
    
    stackLists = String.split(stacks, "\n", trim: true)
      |> List.delete_at(-1)
      |> Enum.reduce([], fn stack, acc ->
        positionedParts = Enum.map(1..numCols, fn col ->
          String.slice(stack, (4*(col-1))..(4*(col-1))+2)
        end)

        acc ++ [positionedParts]
      end)
      |> Enum.reverse()
      |> Enum.reduce([], fn row, acc ->

        if acc == [] do
          Enum.map(row, fn x -> [x] end)
        else
          acc
            |> Enum.with_index
            |> Enum.map(fn({stack, i}) ->
                stack ++ [Enum.at(row, i)]
            end)
        end
      end)
        |> Enum.map(fn bottomUpStack ->
          Enum.filter(bottomUpStack, fn x -> x != "   " end)
          |> Enum.map(fn x ->
            String.replace(x, ~r"[\[\]]", "")
          end)
        end)

    {stackLists, steps}

  end

  def main do
    {stackLists, steps} = parse_input(get_input())

    finalState = Enum.reduce(steps, stackLists, fn step, acc ->
      [count, fromID, toID] = String.replace(step, "move ", "") 
        |> String.replace(" from ", ",") 
        |> String.replace(" to ", ",")
        |> String.split(",")
        |> Enum.map(fn x -> String.to_integer(x) end)

      fromStack = Enum.at(acc, fromID-1)
      toStack = Enum.at(acc, toID-1)

      newFromStack = Enum.slice(fromStack, 0, Enum.count(fromStack)-count)
      newToStack = toStack ++ Enum.take(fromStack, -count)
      
      acc
        |> Enum.with_index
        |> Enum.map(fn({stack, i}) ->
          if i == fromID-1 do
            newFromStack
          else if i == toID-1 do
            newToStack
          else
            stack
          end
          end
        end)
    end)

    Enum.map(finalState, fn stack ->
      Enum.at(stack, -1)
    end) |> Enum.join("")
    
  end
end

IO.inspect(Day5.main())






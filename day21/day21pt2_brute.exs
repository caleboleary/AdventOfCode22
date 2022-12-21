defmodule Day21 do
  def get_input do
    # File.read!("./day21/day21testinput.txt")
    File.read!("./day21/day21input.txt")
        |> String.split("\n", trim: true)
  end

  def parse_input(input) do


    Enum.reduce(input, %{}, fn x, acc ->
      split = String.split(x, ":", trim: true)
      math = Enum.at(split, 1)
      |> String.split(" ", trim: true)

      Map.put(acc, Enum.at(split, 0),
        if Enum.at(math, 2) == nil do
          %{
            component1: nil,
            component2: nil,
            operation: nil,
            result: String.to_integer(Enum.at(math, 0))
          }
        else
          %{
            component1: Enum.at(math, 0),
            component2: Enum.at(math, 2),
            operation: Enum.at(math, 1),
            result: nil
          }
        end
      )
    end)
  end

  def perform_operation(one, two, op) do
    case op do
      "+" -> one + two
      "-" -> one - two
      "*" -> one * two
      "/" -> one / two
    end
  end

  def list_to_map(list) do
    Enum.reduce(list, %{}, fn {x, v}, acc ->
      Map.put(acc, x, v)
    end)
  end

  def get_sim_result(input) do
    Enum.reduce_while(0..100, input, fn x, acc ->
      #sim round
      updatedState = Enum.map(acc, fn {key, value} ->
      
        if value.result != nil do
          {key, value}
        else
          predecessor1 = Map.get(acc, value.component1).result
          predecessor2 = Map.get(acc, value.component2).result

          if predecessor1 != nil and predecessor2 != nil do
            if key == "root" do
              {key, %{value | result: {predecessor1, predecessor2}}}
            else
              {key, %{value | result: perform_operation(predecessor1, predecessor2, value.operation)}}
            end
          else
            {key, value}
          end
        end

      end) |> list_to_map()

      # IO.inspect("updatedState")
      # IO.inspect(updatedState)

      #is root value not nil?
      if Map.get(updatedState, "root").result != nil do
        {:halt, Map.get(updatedState, "root").result}
      else
        {:cont, updatedState}
      end


      
    end)
  end

  def main do

    input = get_input() |> parse_input()
    # IO.inspect(input)

    Enum.reduce_while(0..100000, input, fn index, _acc ->
      if rem(index, 1000) == 0 do
        IO.inspect(index)
      end
    
      ptInput = %{
        input | 
        "humn" => %{input["humn"] | result: index}
      }

      {a, b} = get_sim_result(ptInput)

      if a == b do
        {:halt, index}
      else
        {:cont, index}
      end

    end)
    

  end
end

IO.inspect(Day21.main())
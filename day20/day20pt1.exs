defmodule Day20 do
  def get_input do
    # File.read!("./day20/day20testinput.txt")
    File.read!("./day20/day20input.txt")
        |> String.split("\n", trim: true)
        |> Enum.with_index()
        |> Enum.map(fn {x, i} -> %{
          id: i,
          value: String.to_integer(x)
        } end)
  end

  def reorder_single_num(list, id, len) do
  
    {currPos, value} = Enum.with_index(list) |> Enum.reduce_while({0, 0}, fn {x, index}, acc ->
      if x.id == id do
        {:halt, {index, x.value}}
      else
        {:cont, acc}
      end
    end)

    newPos = rem(currPos + value, len - 1)

    destination = cond do
      newPos < 0 -> newPos - 1
      newPos == 0 -> len
      true -> newPos
    end

    withoutCurr = List.delete_at(list, currPos)
    List.insert_at(withoutCurr, destination, %{id: id, value: value})
  end

  def format_list(list) do
     Enum.with_index(list) |> Enum.map(fn {x, i} -> %{id: i, value: x} end)
  end

  def deformat_list(list) do
    Enum.map(list, fn x -> x.value end)
  end

  def conduct_test(inp, outp, id) do
    sample = format_list(inp)
    res = deformat_list(reorder_single_num(sample, id, length(sample)))
    if (
      res == outp
    )
    do
      true
    else
      IO.inspect("failed test")
      IO.inspect(res)
      IO.inspect(outp)
      IO.inspect("not equal")
      false
    end
  end

  def main do

    # IO.inspect("---------- test cases ----------")

    # IO.inspect(conduct_test([1, 2, -3, 3, -2, 0, 4], [2, 1, -3, 3, -2, 0, 4], 0))
    # IO.inspect(conduct_test([2, 1, -3, 3, -2, 0, 4], [1, -3, 2, 3, -2, 0, 4], 0))
    # IO.inspect(conduct_test([1, -3, 2, 3, -2, 0, 4], [1, 2, 3, -2, -3, 0, 4], 1))
    # IO.inspect(conduct_test([1, -4, 2, 3, -2, 0, 4], [1, 2, 3, -4, -2, 0, 4], 1))
    # IO.inspect(conduct_test([1, -1, 2, 3, -2, 0, 4], [-1, 1, 2, 3, -2, 0, 4], 1))
    # IO.inspect(conduct_test([1, -2, 2, 3, -2, 0, 4], [1, 2, 3, -2, 0, -2, 4], 1))
    # IO.inspect(conduct_test([1, -2, 2, 3, -2, 0, 4], [1, -2, 2, 3, 4, -2, 0], 6))
    # IO.inspect(conduct_test([1, -2, 2, 3, -2, 0, 10], [1, -2, 2, 10, 3, -2, 0], 6))
    # IO.inspect(conduct_test([1, -2, 2, 3, -2, 0, 3], [1, -2, 2, -2, 0, 3, 3], 3))
    # IO.inspect(conduct_test([1, -2, 2, 9, -2, 0, 3], [1, -2, 2, -2, 0, 3, 9], 3))
    # IO.inspect(conduct_test([1, -2, 2, 8, -2, 0, 3], [1, -2, 2, -2, 0, 8, 3], 3))
    # IO.inspect(conduct_test([1, -2, 2, 4, -2, 0, 3], [1, 4, -2, 2, -2, 0, 3], 3))


    # # throw "tests done"

    input = get_input()

    len = length(input)
    
    unMixed = Enum.reduce(0..(len - 1), input, fn i, acc ->
      reorder_single_num(acc, i, len)
    end)

    IO.inspect("unMixed")
    IO.inspect(deformat_list(unMixed) |> Enum.join(", "), limit: :infinity)
    
    indexOf0 = Enum.find_index(unMixed, fn x -> x.value == 0 end)
    IO.inspect(indexOf0)
    oneThousanth = Enum.at(unMixed, rem(indexOf0 + 1000, len)).value
    IO.inspect(oneThousanth)
    twoThousanth = Enum.at(unMixed, rem(indexOf0 + 2000, len)).value
    IO.inspect(twoThousanth)
    threeThousanth = Enum.at(unMixed, rem(indexOf0 + 3000, len)).value
    IO.inspect(threeThousanth)

    oneThousanth + twoThousanth + threeThousanth

  end
end

IO.inspect(Day20.main())
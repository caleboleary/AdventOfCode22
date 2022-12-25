defmodule Day25 do
  def get_input do
    # File.read!("./day25/day25testinput.txt")
    File.read!("./day25/day25input.txt")
        |> String.split("\n", trim: true)
  end

  def snafu_to_decimal(snafu) do
    # 2, 1, 0, -, =

    String.split(snafu, "", trim: true)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {digit, index}, acc ->
      acc + (:math.pow(5, index) *
        case digit do
          "2" -> 2
          "1" -> 1
          "0" -> 0
          "-" -> -1
          "=" -> -2
        end
      )
    end)
  end

  def decimal_to_snafu(decimal) do
    asB5 = Integer.to_string(decimal, 5)

    digits = String.split(asB5, "", trim: true)
    |> Enum.reverse()
    |> Enum.with_index()

   Enum.reduce(digits, %{res: "", remainder: 0}, fn {digit, index}, acc ->

      converted = case String.to_integer(digit) + acc.remainder do
        5 -> "10"
        4 -> "1-"
        3 -> "1="
        2 -> "2"
        1 -> "1"
        0 -> "0"
      end

      if (index == length(digits) - 1) do
        %{res: converted <> acc.res, remainder: 0}
      else
        if (String.length(converted) == 2) do
          %{
            res:  String.slice(converted, 1, 1) <> acc.res,
            remainder: String.slice(converted, 0, 1) |> String.to_integer()
          }
        else
          %{res: converted <> acc.res, remainder: 0}
        end
      end
    end).res
  end


  def main do
    input = get_input()
    
    Enum.map(input, fn line ->
      snafu_to_decimal(line)
    end)
    |> Enum.reduce(0, fn decimal, acc ->
      acc + decimal
    end)
    |> trunc()
    |> decimal_to_snafu()
    

  end
end

IO.inspect(Day25.main())


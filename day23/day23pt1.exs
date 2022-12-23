defmodule Day23 do
  def get_input do
    File.read!("./day23/day23testinput.txt")
    # File.read!("./day23/day23input.txt")
        |> String.split("\n", trim: true)
  end


  def main do
    input = get_input()
    
    

  end
end

IO.inspect(Day23.main())
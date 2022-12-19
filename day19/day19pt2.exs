defmodule DayX do
  def get_input do
    # File.read!("./dayX/dayXtestinput.txt")
    File.read!("./dayX/dayXinput.txt")
        |> String.split("\n", trim: true)
  end


  def main do
    input = get_input()
    
    

  end
end

IO.inspect(DayX.main())
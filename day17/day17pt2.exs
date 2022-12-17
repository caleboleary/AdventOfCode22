#__####
#__
#__.#.
#__###
#__.#.
#__
#__..#
#__..#
#__###
#__
#__#
#__#
#__#
#__#
#__
#__##
#__##

defmodule Day17 do
  def get_input do
    # File.read!("./day17/day17testinput.txt")
    File.read!("./day17/day17input.txt")
        |> String.split("", trim: true)
  end

  def indexOf(string, substr) do
      split = String.split(string, substr)
      if length(split) == 1 do
          -1
      else
          String.length(split |> List.first) + 1
      end
  end

  def get_rock(iteration, highestYCoordsReached) do
    origin = highestYCoordsReached + 3

    case rem(iteration, 5) do
      0 -> [{2, origin}, {3, origin}, {4, origin}, {5, origin}]
      1 -> [{3, origin}, {2, origin + 1}, {3, origin + 1}, {4, origin + 1}, {3, origin + 2}]
      2 -> [{2, origin}, {3, origin}, {4, origin}, {4, origin + 1}, {4, origin + 2}]
      3 -> [{2, origin}, {2, origin + 1}, {2, origin + 2}, {2, origin + 3}]
      4 -> [{2, origin}, {3, origin}, {2, origin + 1}, {3, origin + 1}]
    end
  end

  def get_blown_rock(rockCoords, airJetDir, occupiedCoords) do
    cond do 
      airJetDir == "<" -> 
        # if any of the rockCoords have an x of 0, do nothing
        if Enum.any?(rockCoords, fn {x, _y} -> x == 0 end) do
          rockCoords
        else
          # if any of the rockCoords with 1 subbed from x are present in occupiedCoords, do nothing
          if Enum.any?(rockCoords, fn {x, y} -> Map.has_key?(occupiedCoords, {x - 1, y}) end) do
            rockCoords
          else
            Enum.map(rockCoords, fn {x, y} -> {x - 1, y} end)
          end
        end
      airJetDir == ">" -> 
        # if any of the rockCoords have an x of 6, do nothing
        if Enum.any?(rockCoords, fn {x, _y} -> x == 6 end) do
          rockCoords
        else
          # if any of the rockCoords with 1 added to x are present in occupiedCoords, do nothing
          if Enum.any?(rockCoords, fn {x, y} -> Map.has_key?(occupiedCoords, {x + 1, y}) end) do
            rockCoords
          else
            Enum.map(rockCoords, fn {x, y} -> {x + 1, y} end)
          end
        end
      true -> 
        IO.inspect("airJetDir: #{airJetDir}")
        throw "idk wat do"
    end
  end

  def get_can_rock_move_down?(rockCoords, occupiedCoords) do
    # if any of the rockCoords have a y of 0, return false
    if Enum.any?(rockCoords, fn {_x, y} -> y == 0 end) do
      false
    else
      # if any of the rockCoords with 1 subbed from y are present in occupiedCoords, return false
      if Enum.any?(rockCoords, fn {x, y} -> Map.has_key?(occupiedCoords, {x, y - 1}) end) do
        false
      else
        true
      end
    end
  end

  def visualize_board(occupiedCoords, highestYCoord) do
    # print the board
    IO.puts("")
    for y <- highestYCoord..0 do
      IO.write("|")
      for x <- 0..6 do
        if Map.has_key?(occupiedCoords, {x, y}) do
          IO.write("#")
        else
          IO.write(".")
        end
      end
      IO.write("|")
      IO.puts("")
    end
    IO.puts("+-------+")
  end

  def save_board_to_file(occupiedCoords, highestYCoord) do
    
    board = get_board_as_string(occupiedCoords, highestYCoord)

    #write board to file
    File.write!("day17/day17output.txt", board)

  end

  def get_board_as_string(occupiedCoords, highestYCoord) do
    res = for y <- highestYCoord..0 do
      row = for x <- 0..6 do
        if Map.has_key?(occupiedCoords, {x, y}) do
          "#"
        else
          "."
        end
      end
      "#{row}\n"
    end

    Enum.join(res, "")
  end

  def get_air_jet(airJets, index) do
    Enum.at(airJets, rem(index, Enum.count(airJets)))
  end

  def add_rock_to_occupied_coords(rockCoords, occupiedCoords) do
    Enum.reduce(rockCoords, occupiedCoords, fn {x, y}, acc ->
      Map.put(acc, {x, y}, true)
    end)
  end

  def repeat_check(newState, stepIndex) do
    if (length(newState.rockData) > 40) do
        #each iter, grab the last 20 rockData as a string
        last20 = Enum.slice(newState.rockData, -20, 20) |> Enum.map(fn {index, rock} -> "#{index}-#{rock}" end) |> Enum.join(":")

        # IO.inspect("last20: #{last20}")
        # IO.inspect("all rockData: #{newState.rockData |> Enum.map(fn {index, rock} -> "#{index}-#{rock}" end) |> Enum.join(":")}")

        r = Enum.reduce_while(40..stepIndex, -1, fn i, acc -> 
          prev20 = Enum.slice(newState.rockData, -i, 20) |> Enum.map(fn {index, rock} -> "#{index}-#{rock}" end) |> Enum.join(":")
          # IO.inspect("prev20: #{prev20}")
          if (prev20 == last20) do
            {:halt, i - 20}
          else
            {:cont, -1}
          end
        end)
        

        if rem(1000000000000 - stepIndex, r) === 0 do
          r
        else
          -1
        end
        
    else
      -1
    end
  end

  def main do
    input = get_input()

    accInit = %{
      occupiedCoords: %{},
      highestYCoordsReached: 0,
      currentAirJetIndex: 0,
      rockData: [],
      firstRepeat: nil,
      secondRepeat: nil,
      heightGainRemainder: nil
    }

    results = Enum.reduce_while(0..5500, accInit, fn index, acc -> 
    # results = Enum.reduce_while(0..250, accInit, fn index, acc -> 
      #insert a rock, sim it falling until it hits something, then move to next iteration of the reduce, updating the acc

      rockCoords = get_rock(index, acc.highestYCoordsReached)

      fallSimResults = Enum.reduce_while(0..(acc.highestYCoordsReached + 3), %{fallingRockCoords: rockCoords, airJetIndex: acc.currentAirJetIndex}, fn _i, fallingSimAcc ->
        #if possible, move the rock left or right based on air jet pattern
        airJetDir = get_air_jet(input, fallingSimAcc.airJetIndex)

        # visualize_board(add_rock_to_occupied_coords(fallingSimAcc.fallingRockCoords, acc.occupiedCoords), acc.highestYCoordsReached + 6)

        rockBlown = get_blown_rock(fallingSimAcc.fallingRockCoords, airJetDir, acc.occupiedCoords)

        # visualize_board(add_rock_to_occupied_coords(rockBlown, acc.occupiedCoords), acc.highestYCoordsReached + 6)


        if get_can_rock_move_down?(rockBlown, acc.occupiedCoords) do
          #move the rock down 1 space
          rockFallen = Enum.map(rockBlown, fn {x, y} -> {x, y - 1} end)

          # if get_can_rock_move_down?(rockFallen, acc.occupiedCoords) do
            {:cont, %{fallingRockCoords: rockFallen, airJetIndex: fallingSimAcc.airJetIndex + 1}}
          # else
          #   {:halt, %{fallingRockCoords: rockFallen, airJetIndex: fallingSimAcc.airJetIndex + 1}}
          # end
        else
           {:halt, %{fallingRockCoords: rockBlown, airJetIndex: fallingSimAcc.airJetIndex + 1}}
        end

      end)   

      # IO.inspect(fallSimResults)

      highestCoordThisRockReached = (fallSimResults.fallingRockCoords |> Enum.map(fn {_x, y} -> y end) |> Enum.max()) + 1

      newState = %{
        occupiedCoords: add_rock_to_occupied_coords(fallSimResults.fallingRockCoords, acc.occupiedCoords),
        highestYCoordsReached: if highestCoordThisRockReached > acc.highestYCoordsReached do
            highestCoordThisRockReached
          else
            acc.highestYCoordsReached
          end,
        currentAirJetIndex: fallSimResults.airJetIndex,
        rockData: acc.rockData ++ [{rem(fallSimResults.airJetIndex, length(input)), rem(index, 5)}],
        firstRepeat: acc.firstRepeat,
        secondRepeat: acc.secondRepeat,
        heightGainRemainder: acc.heightGainRemainder
      }

      repeat = 
        if (index === 0) do
          -1
        else
          # if (newState.firstRepeat !== nil) do
            repeat_check(newState, index)
          # else
            # -1
          # end
        end

      turnState = %{
        newState | 
        firstRepeat: if (repeat > -1) and newState.firstRepeat === nil do
          IO.inspect("should only be hit once ever")
          IO.inspect(repeat)
          IO.inspect(newState.firstRepeat)
          %{repeat: repeat, index: index, currHeight: newState.highestYCoordsReached}
        else
          acc.firstRepeat
        end,
        secondRepeat: if newState.firstRepeat !== nil and index === newState.firstRepeat.index + newState.firstRepeat.repeat do
          IO.inspect("should only be hit once ever")
          IO.inspect(repeat)
          IO.inspect(newState.firstRepeat)
          %{index: index, currHeight: newState.highestYCoordsReached}
        else
          acc.secondRepeat
        end,
        heightGainRemainder: if newState.heightGainRemainder == nil and newState.firstRepeat !== nil and index === (newState.firstRepeat.index + 131) do
          # IO.inspect("should only be hit once ever")
          # IO.inspect(repeat)
          # IO.inspect(newState.firstRepeat)
          (newState.highestYCoordsReached - newState.firstRepeat.currHeight) - 1
        else
          acc.heightGainRemainder
        end
      }

      {:cont, turnState}
    end)

    IO.inspect("loop data:")
    IO.inspect(results.firstRepeat)
    IO.inspect(results.secondRepeat)

   
    loopsLeft = floor((1000000000000 - results.firstRepeat.index) / (results.firstRepeat.repeat))
    IO.inspect("loopsLeft")
    IO.inspect(loopsLeft)

    # need to get this remainder to 0 or calc how much it stacks on the end
    remainingPartialTopLoop = rem((1000000000000 - results.firstRepeat.index), (results.firstRepeat.repeat))
    IO.inspect("remainingPartialTopLoop")
    IO.inspect(remainingPartialTopLoop)
    IO.inspect(results.heightGainRemainder)

    heightChangePerLoop = results.secondRepeat.currHeight - results.firstRepeat.currHeight
    IO.inspect("heightChangePerLoop")
    IO.inspect(heightChangePerLoop)


    IO.inspect(
      (loopsLeft * heightChangePerLoop) + (results.firstRepeat.currHeight) - 1
    )
    IO.inspect(1514285714288)


    #save rockData to file
    File.write!("day17/day17output.txt", results.rockData |> Enum.map(fn {index, rock} -> "#{index}: #{rock}" end) |> Enum.join("\n"))
    rrd = results.rockData
    |> Enum.reverse()

    strRrd = rrd |> Enum.map(fn {index, rock} -> "#{index}: #{rock}" end) |> Enum.join("\n")


    IO.inspect(results.highestYCoordsReached)
  end
end

IO.inspect(Day17.main())
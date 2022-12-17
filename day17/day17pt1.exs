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

  def get_air_jet(airJets, index) do
    Enum.at(airJets, rem(index, Enum.count(airJets)))
  end

  def add_rock_to_occupied_coords(rockCoords, occupiedCoords) do
    Enum.reduce(rockCoords, occupiedCoords, fn {x, y}, acc ->
      Map.put(acc, {x, y}, true)
    end)
  end

  def main do
    input = get_input()

    accInit = %{
      occupiedCoords: %{},
      highestYCoordsReached: 0,
      currentAirJetIndex: 0,      
    }

    results = Enum.reduce(0..2021, accInit, fn index, acc -> 
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

      %{
        occupiedCoords: add_rock_to_occupied_coords(fallSimResults.fallingRockCoords, acc.occupiedCoords),
        highestYCoordsReached: if highestCoordThisRockReached > acc.highestYCoordsReached do
            highestCoordThisRockReached
          else
            acc.highestYCoordsReached
          end,
        currentAirJetIndex: fallSimResults.airJetIndex
      }   
    end)


    visualize_board(results.occupiedCoords, results.highestYCoordsReached)

    IO.inspect(results.highestYCoordsReached)
  end
end

IO.inspect(Day17.main())
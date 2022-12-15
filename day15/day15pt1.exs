defmodule Day15 do
  def get_input do
    # File.read!("./day15/day15testinput.txt")
    File.read!("./day15/day15input.txt")
        |> String.split("\n", trim: true)
  end

  def parse_input(rawInput) do
    Enum.map(rawInput, fn line ->
      split = String.split(line, ": closest beacon is at ")
      [dFirst, second] = split
      first = String.replace(dFirst, "Sensor at ", "")

      [dfirstX, firstY] = String.split(first, ", y=")
      firstX = String.replace(dfirstX, "x=", "")

      firstCoords = {String.to_integer(firstX), String.to_integer(firstY)}

      [dsecondX, secondY] = String.split(second, ", y=")
      secondX = String.replace(dsecondX, "x=", "")

      secondCoords = {String.to_integer(secondX), String.to_integer(secondY)}

      %{
        sensor: firstCoords,
        beacon: secondCoords
      }
    end)
  end

  def add_manhattan_distances(positions) do
    Enum.map(positions, fn beaconPosition ->
      %{
        sensor: beaconPosition.sensor,
        beacon: beaconPosition.beacon,
        distance: abs((beaconPosition.sensor |> elem(0)) - (beaconPosition.beacon |> elem(0))) + abs((beaconPosition.sensor |> elem(1)) - (beaconPosition.beacon |> elem(1)))
      }
    end)
  end

  def get_blocked_cells_in_target_row(targetRowIndex, positions) do
    Enum.flat_map(positions, fn beaconPosition ->
      if (beaconPosition.distance < abs(targetRowIndex - (beaconPosition.sensor |> elem(1)))) do
        []
      else
        centralCell = {beaconPosition.sensor |> elem(0), targetRowIndex}
        # for each y distance we are away, we step to the left and right 1 less time from centralCell
        # ie if we are 1 row away and the sensor distance is 9, we step 8 to the left and 8 to the right
        # if we are 2 rows away and the sensor distance is 9, we step 7 to the left and 7 to the right
        # if we are 9 rows away and the sensor distance is 9, we step 0 to the left and 0 to the right

        numStepsEachDir = beaconPosition.distance - abs(targetRowIndex - (beaconPosition.sensor |> elem(1)))

        cellsToLeft = Enum.map(0..numStepsEachDir, fn x ->
          {(centralCell |> elem(0)) - x, centralCell |> elem(1)}
        end)

        cellsToRight = Enum.map(0..numStepsEachDir, fn x ->
          {(centralCell |> elem(0)) + x, centralCell |> elem(1)}
        end)

        [centralCell] ++ cellsToLeft ++ cellsToRight
      end
    end)
  end


  def main do
    input = get_input()
    positions = parse_input(input)

    withDist = add_manhattan_distances(positions)

    blockedCells = get_blocked_cells_in_target_row(2000000, withDist) |> Enum.uniq()

    #remove any cells which are beacons or sensors
    nonOccupiedBlockedCells = Enum.filter(blockedCells, fn cell ->
      Enum.all?(positions, fn position ->
        cell != position.beacon && cell != position.sensor
      end)
    end)

    # sort by x
    sortedCells = Enum.sort_by(nonOccupiedBlockedCells, fn cell ->
      cell |> elem(0)
    end)
    

    length(sortedCells)

  end
end

IO.inspect(Day15.main())
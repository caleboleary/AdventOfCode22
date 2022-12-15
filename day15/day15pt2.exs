defmodule Day15 do
  def get_input do
    # File.read!("./day15/day15testinput.txt")
    File.read!("./day15/day15input.txt")
        |> String.split("\n", trim: true)
  end

  # def upper_bound do 20 end
  def upper_bound do 4000000 end

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

  def get_manhattan_distance(a, b) do
    abs((a |> elem(0)) - (b |> elem(0))) + abs((a |> elem(1)) - (b |> elem(1)))
  end

  def add_manhattan_distances(positions) do
    Enum.map(positions, fn beaconPosition ->
      %{
        sensor: beaconPosition.sensor,
        beacon: beaconPosition.beacon,
        distance: get_manhattan_distance(beaconPosition.sensor, beaconPosition.beacon)
      }
    end)
  end

  def get_sensor_perimeter(sensor, distance) do
    perimPoints = Enum.flat_map(0..distance, fn x ->
      # for each distance, we can determine 4 points along the perimeter. For 0 and {distance} there will be dupes, we can uniq them out.

      #for example if distance is 9, and our sensor is {8,7}
      # at distance 0, we have 4 points: {-1, 7}, {17, 7}, {-1, 7}, {17, 7}
      # at distance 1, we have 4 points: {0, 6}, {16, 6}, {0, 8}, {16, 8}
      # at distance 4 we have 4 points: {3, 3}, {13, 3}, {3, 11}, {13, 11}

      [
        {(sensor |> elem(0)) - x, (sensor |> elem(1)) - distance + x},
        {(sensor |> elem(0)) + distance - x, (sensor |> elem(1)) - x},
        {(sensor |> elem(0)) + x, (sensor |> elem(1)) + distance - x},
        {(sensor |> elem(0)) - distance + x, (sensor |> elem(1)) + x}
      ]
    end)
    IO.inspect("a perimeter was found")
    perimPoints
  end

  def get_is_cell_blocked(cell, positions) do
    #for each position, if the distance to the cell is less than the distance to the sensor, then the cell is blocked
    if cell |> elem(0) < 0 or cell |> elem(0) > upper_bound() or cell |> elem(1) < 0 or cell |> elem(1) > upper_bound() do
      true
    else
      Enum.any?(positions, fn beaconPosition ->
        if (cell === {14,11}) do
        end
        if (get_manhattan_distance(cell, beaconPosition.sensor) > beaconPosition.distance) do
          false
        else
          true
        end
      end)
    end
  end

  def main do
    input = get_input()
    positions = parse_input(input)
    IO.inspect(length(positions))

    withDist = add_manhattan_distances(positions)

    #get all perimeter points in one huge map
    perimeter = Enum.flat_map(withDist, fn beaconPosition ->
      get_sensor_perimeter(beaconPosition.sensor, beaconPosition.distance)
    end) 
    # |> Enum.uniq()
    # |> Enum.filter(fn cell ->
    #   (cell |> elem(0)) >= 0 and (cell |> elem(0)) <= upper_bound() and (cell |> elem(1)) >= 0 and (cell |> elem(1)) <= upper_bound()
    # end)
    # |> Enum.sort_by(fn cell ->
    #   cell |> elem(0)
    # end)

    IO.inspect("perimeters points found")
    IO.inspect(length(perimeter))

    # IO.inspect(perimeter)

    #for each perimeter point, check the blocked state of the four cells up left down right of it

    realBeacon = Enum.reduce_while(perimeter, {-1,-1}, fn cell, acc ->
      IO.inspect("checking cell neighbors")

      above = {cell |> elem(0), (cell |> elem(1)) - 1}
      left = {(cell |> elem(0)) - 1, cell |> elem(1)}
      below = {cell |> elem(0), (cell |> elem(1)) + 1}
      right = {(cell |> elem(0)) + 1, cell |> elem(1)}

      isAboveBlocked = get_is_cell_blocked(above, withDist)
      isLeftBlocked = get_is_cell_blocked(left, withDist)
      isBelowBlocked = get_is_cell_blocked(below, withDist)
      isRightBlocked = get_is_cell_blocked(right, withDist)

      cond do 
        isAboveBlocked == false -> {:halt, above}
        isLeftBlocked == false -> {:halt, left}
        isBelowBlocked == false -> {:halt, below}
        isRightBlocked == false -> {:halt, right}
        true -> {:cont, acc}
      end
      
    end)

    ((realBeacon |> elem(0)) * 4000000) + (realBeacon |> elem(1))



  end
end

IO.inspect(Day15.main())
defmodule Day14 do
  def get_input do
    # File.read!("./day14/day14testinput.txt")
    File.read!("./day14/day14input.txt")
        |> String.split("\n", trim: true)
  end

  def visualize_map(map) do
    IO.inspect("map: ")
    IO.inspect("-------------------------------")
    Enum.map(map, fn row -> 
      if is_list(row) do
        IO.inspect(Enum.join(row, ""))
      else
        IO.inspect(Enum.join(Tuple.to_list(row), ""))
      end
    end)
    IO.inspect("-------------------------------")
  end

  def fast_at(tup, index) do
    if is_list(tup) do
      Enum.at(tup, index)
    else
      tup |> elem(index)
    end
  end

  def muh_len(thing) do
    if is_list(thing) do
      length(thing)
    else
      tuple_size(thing)
    end
  end

  def insert_rock_vein(map, veinPointList, smallestX, smallestY) do
    # example veinPointList:
    # [[503, 4], [502, 4], [502, 9], [494, 9]]
    # first part is on y 4, from x 503 to x 502
    # second part is on x 502, from y 4 to y 9
    # third part is on y 9, from x 502 to x 494
    # so let's generate a list of all points which need to become rock
    # and then insert them into the map
    # for example, [[503, 4], [502, 4], [502, 4], [502, 5], [502, 6], [502, 7], [502, 8], [502, 9], [501, 9], [500, 9], [499, 9], [498, 9], [497, 9], [496, 9], [495, 9], [494, 9]]
    # can we use ranges?

    #expand 
    # [[503, 4], [502, 4], [502, 9], [494, 9]]
    # to
    # [[503, 4], [502, 4], [502, 4], [502, 5], [502, 6], [502, 7], [502, 8], [502, 9], [501, 9], [500, 9], [499, 9], [498, 9], [497, 9], [496, 9], [495, 9], [494, 9]]

    expandedPoints = Enum.flat_map(0..muh_len(veinPointList) - 2, fn index -> 
      point1 = fast_at(veinPointList, index)
      point2 = fast_at(veinPointList, index + 1)
      if fast_at(point1, 0) == fast_at(point2, 0) do
        # x is the same, so we need to expand on y
        Enum.map(fast_at(point1, 1)..fast_at(point2, 1), fn y -> 
          [fast_at(point1, 0), y]
        end)
      else
        # y is the same, so we need to expand on x
        Enum.map(fast_at(point1, 0)..fast_at(point2, 0), fn x -> 
          [x, fast_at(point1, 1)]
        end)
      end
    end)
    |> Enum.uniq()

    # return map with expandedPoints converted into "#"
    Enum.map(0..muh_len(map) - 1, fn y -> 
      Enum.map(0..muh_len(fast_at(map, y)) - 1, fn x -> 
        #add smallestX and smallestY to x and y to get the actual coordinates
        if Enum.member?(expandedPoints, [x + smallestX, y + smallestY]) do
          "#"
        else
          fast_at(fast_at(map, y), x)
        end
      end)
    end)


  end

  def get_map_dimensions(input) do
    allVertices = Enum.flat_map(input, fn line -> 
      String.split(line, " -> ", trim: true)
    end)
    |> Enum.map(fn line -> 
      String.split(line, ",", trim: true)
    end)
    |> Enum.map(fn pair -> 
      [String.to_integer(fast_at(pair, 0)), String.to_integer(fast_at(pair, 1))]
    end)

    sortedByX = Enum.sort_by(allVertices, fn pair -> 
      fast_at(pair, 0)
    end)

    sortedByY = Enum.sort_by(allVertices, fn pair -> 
      fast_at(pair, 1)
    end)

    # largestX = fast_at(sortedByX, -1) |> fast_at(0)
    largestX = 1000
    # smallestX = fast_at(sortedByX, 0) |> fast_at(0)
    smallestX = 0
    largestY = fast_at(sortedByY, -1) |> fast_at(1)
    # smallestY = fast_at(sortedByY, 0) |> fast_at(1)
    smallestY = 0


    #adding some padding
    {largestX + 1, smallestX - 1, largestY + 1, smallestY}
  end

  def create_empty_map(width, height) do
    Enum.map(0..(height - 1), fn _ -> 
      Enum.map(0..(width - 1), fn _ -> 
        "."
      end)
    end)
  end

  def move_sand_from_to(map, [fromx, fromy], [tox, toy]) do

    newMap = Enum.slice(map, 0, fromy) ++
      [Enum.map(0..muh_len(fast_at(map, fromy)) - 1, fn x -> 
        if x == fromx do
          "."
        else
          fast_at(fast_at(map, fromy), x)
        end
      end)] ++
      Enum.slice(map, fromy + 1, toy - fromy - 1) ++
      [Enum.map(0..muh_len(fast_at(map, toy)) - 1, fn x -> 
        if x == tox do
          "o"
        else
          fast_at(fast_at(map, toy), x)
        end
      end)] ++
      Enum.slice(map, toy + 1, muh_len(map) - toy - 1)

  end


  def main do
    input = get_input()

    {largestX, smallestX, largestY, smallestY} = get_map_dimensions(input)

    mapWidth = largestX - smallestX + 1
    mapHeight = largestY - smallestY + 3

    map = create_empty_map(1000, mapHeight)

    visualize_map(map)
    
    rockVeins = Enum.map(input, fn line -> 
      String.split(line, " -> ", trim: true)
      |> Enum.map(fn pair -> 
        String.split(pair, ",", trim: true)
        |> Enum.map(fn num -> 
          String.to_integer(num)
        end)
      end)
    end)
    ++ [[[smallestX, largestY+1], [largestX, largestY+1]]]

    IO.inspect(rockVeins)

    mapWithRockVeins = Enum.reduce(rockVeins, map, fn rockVein, mapAcc -> 
      insert_rock_vein(mapAcc, rockVein, smallestX, smallestY)
    end)

    visualize_map(mapWithRockVeins)

    sandSource = [500 - smallestX, 0]

    mapWithSandSource = Enum.map(0..muh_len(mapWithRockVeins) - 1, fn y -> 
      Enum.map(0..muh_len(fast_at(mapWithRockVeins, y)) - 1, fn x -> 
        if [x, y] == sandSource do
          "+"
        else
          fast_at(fast_at(mapWithRockVeins, y), x)
        end
      end)
    end) |> Enum.map(fn x ->
      List.to_tuple(x) 
    end)

    visualize_map(mapWithSandSource)

    # start simulating sand falling in.
    # if sand y ever becomes hits largestY, we're done, as it's past the lowest rock vein.
    # insert a piece of sand immediately below sand source
    # while any of: below sand, below sand and to right, below sand and to left are air, keep falling, else move to next sand
    # let's limit to 100k iterations for now
    simResults = Enum.reduce_while(0..100000, %{sandDropped: 1, map: mapWithSandSource}, fn index, sandCountAcc ->
      IO.inspect(index)

      currentMap  = sandCountAcc.map

      mapWithSandBelowSource = Enum.map(0..muh_len(currentMap) - 1, fn y -> 
        Enum.map(0..muh_len(fast_at(currentMap, y)) - 1, fn x -> 
          if [x, y] == sandSource do
            "o"
          else
            fast_at(fast_at(currentMap, y), x)
          end
        end)
      end)

      # visualize_map(mapWithSandBelowSource)

      mapWithSandSettled = Enum.reduce_while(0..10000, %{
        map: mapWithSandBelowSource,
        sandSettled: false,
        lastMovedSandPosition: [fast_at(sandSource, 0), fast_at(sandSource, 1)],
        endSimulation: false
      }, fn _index, fallingSandAcc ->

        fallingMap = fallingSandAcc.map
        [lastX, lastY] = fallingSandAcc.lastMovedSandPosition

        cond do
          lastY == 0 and fast_at(fast_at(fallingMap, lastY + 1), lastX) == "o" and fast_at(fast_at(fallingMap, lastY + 1), lastX - 1) == "o" and fast_at(fast_at(fallingMap, lastY + 1), lastX + 1) == "o" ->
            # sand has reached the bottom of the map
            IO.inspect("end sim hit")
            {:halt, %{map: fallingMap, sandSettled: true, lastMovedSandPosition: [lastX, lastY], endSimulation: true}}
          fast_at(fast_at(fallingMap, lastY + 1), lastX) == "." ->
            # sand below is air, so move sand down
            # move sand as far straight down as possible when it passes through .s
            targetY = Enum.reduce_while(lastY + 1..muh_len(fallingMap) - 1, lastY + 1, fn y, targetYAcc ->
              if fast_at(fast_at(fallingMap, y), lastX) == "." do
                {:cont, y}
              else
                {:halt, targetYAcc}
              end
            end)

            mapWithSandMovedDown = move_sand_from_to(fallingMap, [lastX, lastY], [lastX, targetY])
            {:cont, %{map: mapWithSandMovedDown, sandSettled: false, lastMovedSandPosition: [lastX, targetY], endSimulation: false}}
          fast_at(fast_at(fallingMap, lastY + 1), lastX - 1) == "." ->
            # sand below and to left is air, so move sand down and left
            mapWithSandMovedDown = move_sand_from_to(fallingMap, [lastX, lastY], [lastX - 1, lastY + 1])
            {:cont, %{map: mapWithSandMovedDown, sandSettled: false, lastMovedSandPosition: [lastX - 1, lastY + 1], endSimulation: false}}
          fast_at(fast_at(fallingMap, lastY + 1), lastX + 1) == "." ->
            # sand below and to right is air, so move sand down and right
            mapWithSandMovedDown = move_sand_from_to(fallingMap, [lastX, lastY], [lastX + 1, lastY + 1])
            {:cont, %{map: mapWithSandMovedDown, sandSettled: false, lastMovedSandPosition: [lastX + 1, lastY + 1], endSimulation: false}}
          true ->
            # sand is settled
            {:halt, %{map: fallingMap, sandSettled: true, lastMovedSandPosition: [lastX, lastY], endSimulation: false}}
        end

      end) 
       
      # visualize_map(mapWithSandSettled.map)

      if mapWithSandSettled.endSimulation do
        {:halt, %{sandDropped: sandCountAcc.sandDropped, map: mapWithSandSettled.map}}
      else
        {:cont, %{sandDropped: sandCountAcc.sandDropped + 1, map: mapWithSandSettled.map}}
      end



    end)

    visualize_map(simResults.map)
    simResults.sandDropped


  
    
    

  end
end

IO.inspect(Day14.main())
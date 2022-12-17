defmodule Day16 do
  def get_input do
    # File.read!("./day16/day16testinput.txt")
    File.read!("./day16/day16input.txt")
        |> String.split("\n", trim: true)
  end

  def parse_input(input) do
    Enum.reduce(input, %{}, fn line, acc ->
      [valve, rest] = String.split(line, " has flow rate=")
      [flowRate, tunnels] = 
        if String.contains?(rest, "tunnels") do
          String.split(rest, "; tunnels lead to valves ")
        else
          String.split(rest, "; tunnel leads to valve ")
        end
      tunnels = String.split(tunnels, ", ")

      Map.put(acc, String.replace(valve, "Valve ", ""), %{
        flow_rate: String.to_integer(flowRate),
        connects_to: tunnels
      })
    end)

  end

  def get_path_flow_value(tunnels, path) do
    Enum.reduce(path, %{
      flowed: 0,
      flowRate: 0,
    }, fn actions, acc ->

      newFlowed = acc.flowed + acc.flowRate

      yourFlowAddition = 
        if (actions.you |> elem(0) == :open) do
          Map.get(tunnels, actions.you |> elem(1)).flow_rate
        else
          0
        end

      elephantFlowAddition = 
        if (actions.elephant |> elem(0) == :open) do
          Map.get(tunnels, actions.elephant |> elem(1)).flow_rate
        else
          0
        end
      
      newFlowRate = acc.flowRate + yourFlowAddition + elephantFlowAddition

      %{
        flowed: newFlowed,
        flowRate: newFlowRate
      }
    end).flowed

  end

  def get_possible_next_paths(tunnels, paths) do

    valvesWithFlow = Enum.filter(tunnels, 
          fn {_, tunnelDeets} -> 
            tunnelDeets.flow_rate > 0
          end
        )

    Enum.flat_map(paths, fn path ->

      if (is_list(path.openValves) and length(path.openValves) >= length(
        Enum.filter(tunnels, 
          fn {_, tunnelDeets} -> 
            tunnelDeets.flow_rate > 0
          end
        )
      )) do
        [%{
          path: path.path ++ [%{
            you: {:none, :none},
            elephant: {:none, :none}
          }],
          openValves: path.openValves
        }]
      else

        yourLastValue = List.last(path.path).you |> elem(1)
        elephantLastValue = List.last(path.path).elephant |> elem(1)

        yourPossibleNextActions = (Map.get(tunnels, yourLastValue).connects_to
          |> Enum.map(fn nextValve ->
            {:move, nextValve}
          end))
          ++ if (Enum.member?(path.openValves, yourLastValue) or Map.get(tunnels, yourLastValue).flow_rate == 0) do
            []
          else
            [{:open, yourLastValue}]
          end
        elephantPossibleNextActions = (Map.get(tunnels, elephantLastValue).connects_to
          |> Enum.map(fn nextValve ->
            {:move, nextValve}
          end)) 
          ++ if (Enum.member?(path.openValves, elephantLastValue)) do
            []
          else
            [{:open, elephantLastValue}]
          end

        combos = Enum.flat_map(yourPossibleNextActions, fn yourPath ->
          Enum.map(elephantPossibleNextActions, fn elephantPath ->
            %{you: yourPath, elephant: elephantPath}
          end)
          |> Enum.filter(fn combo -> 
            not ((combo.you |> elem(1) == combo.elephant |> elem(1)) and (combo.you |> elem(0) == :open and combo.elephant |> elem(0) == :open))
          end)
        end)

         Enum.map(combos, fn combo ->
            %{
              path: path.path ++ [combo],
              openValves: path.openValves ++ (if (combo.you |> elem(0) == :open) do
                # IO.inspect("adding #{combo.you |> elem(1)} to open valves")
                [combo.you |> elem(1)]
              else
                []
              end) ++ (if (combo.elephant |> elem(0) == :open) do
                # IO.inspect("adding #{combo.elephant |> elem(1)} to open valves")
                [combo.elephant |> elem(1)]
              else
                []
              end)
            }
          end)

      end
    end)

  end

  def get_all_possible_paths(tunnels, depth) do

    Enum.reduce(0..depth, %{
      paths: [],
    }, fn index, acc ->

      if (index == 0) do
        yourPossiblePaths = Map.get(tunnels, "AA").connects_to
        elephantPossiblePaths = Map.get(tunnels, "AA").connects_to
        combos = Enum.flat_map(yourPossiblePaths, fn yourPath ->
          Enum.map(elephantPossiblePaths, fn elephantPath ->
            %{you: {:move, yourPath}, elephant: {:move, elephantPath}}
          end)
        end)

        %{
          paths: Enum.map(combos, fn combo ->
            %{
              path: [combo],
              openValves: ["AA"]
            }
          end)
        }
      else
        next = %{
          paths: get_possible_next_paths(tunnels, acc.paths)
        }
      end

      # Enum.flat_map(acc, fn path ->
      #   get_possible_next_paths(tunnels, path)
      # end)

    end)



    
  end


  def main do
    input = get_input()
    parsedInput = parse_input(input)


    firstDepth = 6
    pruneTo = 100000

    allPossiblePaths = get_all_possible_paths(parsedInput, firstDepth)

    firstBatch = Enum.map(allPossiblePaths.paths, fn path ->
      %{
        path: path.path, #lol
        openValves: path.openValves,
        flowed: get_path_flow_value(parsedInput, path.path)
      }
    end) 
    |> Enum.sort_by(fn x -> x.flowed end)
    |> Enum.reverse()
    |> Enum.slice(0, pruneTo)

    IO.inspect("firstBatch first entry")
    IO.inspect(Enum.at(firstBatch, 0))
    IO.inspect(length(firstBatch))

    finalResults = Enum.reduce(0..(26 - (firstDepth + 2)), firstBatch, fn index, acc ->
      expandedBatch = get_possible_next_paths(parsedInput, acc)
      newBatch = Enum.map(expandedBatch, fn path ->
        %{
          path: path.path, #lol
          openValves: path.openValves,
          flowed: get_path_flow_value(parsedInput, path.path)
        }
      end)
      |> Enum.sort_by(fn x -> x.flowed end)
      |> Enum.reverse()
      |> Enum.slice(0, pruneTo)
    end)

    IO.inspect(Enum.at(finalResults, 0))   

  end
end

IO.inspect(Day16.main())
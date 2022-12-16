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
    }, fn action, acc ->
      case action do
        {:move, nextValve} ->
          %{
            flowed: acc.flowed + acc.flowRate,
            flowRate: acc.flowRate,
          }
        {:open, nextValve} ->
          nextValveFlowRate = acc.flowRate + Map.get(tunnels, nextValve).flow_rate
          %{
            flowed: acc.flowed + acc.flowRate,
            flowRate: nextValveFlowRate,
          }
        {:none, :none} ->
          %{
            flowed: acc.flowed + acc.flowRate,
            flowRate: acc.flowRate,
          }
      end
    end)

  end

  def get_possible_next_paths(tunnels, paths) do

    Enum.flat_map(paths, fn path ->

      # IO.inspect(length(path.openValves))
      # IO.inspect(length(Map.keys(tunnels)))
      if (is_list(path.openValves) and length(path.openValves) == length(Map.keys(tunnels))) do
        [%{
          path: path.path ++ [{:none, :none}],
          openValves: path.openValves
        }]
      else
        lastValve = List.last(path.path) |> elem(1)
        nextValves = Enum.map(Map.get(tunnels, lastValve).connects_to, fn nextValve ->
            {:move, nextValve}
        end)
        ++ if (Enum.member?(path.openValves, lastValve)) do
          []
        else
          [{:open, lastValve}]
        end

        nextValves
        |> Enum.map(fn nextValve ->
            if (nextValve == {:open, lastValve}) do
              %{
                path: path.path ++ [nextValve],
                openValves: path.openValves ++ [lastValve]
              }
            else
              %{
                path: path.path ++ [nextValve],
                openValves: path.openValves
              }
            end
        end)
      end
    end)

  end

  def get_all_possible_paths(tunnels, depth) do

    Enum.reduce(0..depth, %{
      paths: [],
    }, fn index, acc ->

      if (index == 0) do
        %{
          paths: Enum.map(Map.get(tunnels, "AA").connects_to, fn nextValve ->
            %{
              path: [{:move, nextValve}],
              openValves: ["AA"]
            }
          end)
        }
      else
        %{
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

    firstDepth = 10
    pruneTo = 1000

    allPossiblePaths = get_all_possible_paths(parsedInput, firstDepth)

    firstBatch = Enum.map(allPossiblePaths.paths, fn path ->
      %{
        path: path.path, #lol
        openValves: path.openValves,
        flowed: get_path_flow_value(parsedInput, path.path).flowed
      }
    end) 
    |> Enum.sort_by(fn x -> x.flowed end)
    |> Enum.reverse()
    |> Enum.slice(0, pruneTo)

    IO.inspect(Enum.at(firstBatch, 0))

    finalResults = Enum.reduce(0..(30 - (firstDepth + 2)), firstBatch, fn index, acc ->
      expandedBatch = get_possible_next_paths(parsedInput, acc)
      newBatch = Enum.map(expandedBatch, fn path ->
        %{
          path: path.path, #lol
          openValves: path.openValves,
          flowed: get_path_flow_value(parsedInput, path.path).flowed
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
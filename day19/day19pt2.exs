defmodule Day19 do
  def get_input do
    # File.read!("./day19/day19testinput.txt")
    File.read!("./day19/day19input.txt")
        |> String.split("\n", trim: true)
  end

  # input = ["Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian."]
  # output = [
    # %{
      #   "oreBot" => %{
      #     "ore" => 4
      #   },
      #   "clayBot" => %{
      #     "ore" => 2
      #   },
      #   "obsBot" => %{
      #     "ore" => 3,
      #     "clay" => 14
      #   },
      #   "geoBot" => %{
      #     "ore" => 2,
      #     "obs" => 7
      #   }
      # }
  def parse_input(input) do
    input
    |> Enum.map(fn line ->
      [id, blueprint] = String.split(line, ": ", trim: true)
      trimmedId = String.replace(id, "Blueprint ", "") |> String.to_integer()
      blueprintDetails = String.split(blueprint, "Each ", trim: true) 
      |> Enum.map(fn blueprintDetail ->
        [_, costs] = String.split(blueprintDetail, " costs ", trim: true)
        splCosts = String.split(costs, " and ", trim: true)
        |> Enum.reduce(%{}, fn cost, acc ->
          [num, type] = String.split(cost, " ", trim: true)
          Map.put(acc, String.replace(type, ".", "") |> String.replace("obsidian", "obs") |> String.to_atom(), String.to_integer(num))
        end)
      end)
    
       %{
        :oreBot => Enum.at(blueprintDetails, 0),
        :clayBot => Enum.at(blueprintDetails, 1),
        :obsBot => Enum.at(blueprintDetails, 2),
        :geoBot => Enum.at(blueprintDetails, 3)
      }
     
    end)
  end

  def get_possible_actions(gameState, bluePrint) do
    actions = %{
      buildOreBot: if gameState[:ore] >= bluePrint[:oreBot][:ore] do true else false end,
      buildClayBot: if gameState[:ore] >= bluePrint[:clayBot][:ore] do true else false end,
      buildObsBot: if gameState[:ore] >= bluePrint[:obsBot][:ore] and gameState[:clay] >= bluePrint[:obsBot][:clay] do true else false end,
      buildGeoBot: if gameState[:ore] >= bluePrint[:geoBot][:ore] and gameState[:obs] >= bluePrint[:geoBot][:obs] do true else false end,    
      none: true
    }
  end

  def get_updated_resource_counts(gameState) do
    %{
      gameState |
      :ore => gameState[:ore] + gameState[:oreBot],
      :clay => gameState[:clay] + gameState[:clayBot],
      :obs => gameState[:obs] + gameState[:obsBot],
      :geo => gameState[:geo] + gameState[:geoBot]
    }
  end

  def apply_action(gameState, bluePrint, action) do
    case action do
      :buildOreBot -> %{
        gameState |
        :ore => gameState[:ore] - bluePrint[:oreBot][:ore],
        :oreBot => gameState[:oreBot] + 1
      }
      :buildClayBot -> %{
        gameState |
        :ore => gameState[:ore] - bluePrint[:clayBot][:ore],
        :clayBot => gameState[:clayBot] + 1
      }
      :buildObsBot -> %{
        gameState |
        :ore => gameState[:ore] - bluePrint[:obsBot][:ore],
        :clay => gameState[:clay] - bluePrint[:obsBot][:clay],
        :obsBot => gameState[:obsBot] + 1
      }
      :buildGeoBot -> %{
        gameState |
        :ore => gameState[:ore] - bluePrint[:geoBot][:ore],
        :obs => gameState[:obs] - bluePrint[:geoBot][:obs],
        :geoBot => gameState[:geoBot] + 1
      }
      :none -> gameState
    end
  end

  # # dfs
  # def simulateGame(gameState, bluePrint, depth) do
  #   IO.inspect(depth)
  #   if depth == 24 do
  #     updatedGameState = get_updated_resource_counts(gameState)
  #     [updatedGameState[:geo]]
  #   else
  #     possibleActions = get_possible_actions(gameState, bluePrint) 
  #       |> Enum.filter(fn {key, value} -> value == true end) 
  #       |> Enum.map(fn {key, value} -> key end)

  #     updatedGameState = get_updated_resource_counts(gameState)

  #     res2 = Enum.flat_map(possibleActions, fn action ->
  #       res = simulateGame(apply_action(updatedGameState, bluePrint, action), bluePrint, depth + 1)
  #     end)
  #   end
  # end

  def get_time_distance_to_next_clayBot(gameState, bluePrint) do
    #time to get enough ore for clayBot:
    oreNeeded = Enum.max([(bluePrint[:clayBot][:ore] - gameState[:ore]) / (gameState[:oreBot] + 1), 0])
    # IO.inspect("oreNeeded for clay #{oreNeeded}")
    oreNeeded
  end

  def get_time_distance_to_next_obsBot(gameState, bluePrint) do
    #time to get enough ore for obsBot:
    oreNeeded = Enum.max([(bluePrint[:obsBot][:ore] - gameState[:ore]) / (gameState[:oreBot] + 1), 0])
    # IO.inspect("oreNeeded for obs #{oreNeeded}")


    #time to get enough clay for obsBot:
    clayNeeded = if gameState[:clayBot] < 1 do
      get_time_distance_to_next_clayBot(gameState, bluePrint) + bluePrint[:obsBot][:clay]
    else
      Enum.max([(bluePrint[:obsBot][:clay] - gameState[:clay]) / (gameState[:clayBot] + 1), 0])
    end

    # IO.inspect("clayNeeded for obs #{clayNeeded}")

    oreNeeded + clayNeeded

  end

  def get_time_distance_to_next_geoBot(gameState, bluePrint) do
    #time to get enough ore for geoBot:
    oreNeeded = Enum.max([(bluePrint[:geoBot][:ore] - gameState[:ore]) / (gameState[:oreBot] + 1), 0])
    # IO.inspect("oreNeeded for geo #{oreNeeded}")

    #time to get enough obs for geoBot:
    obsNeeded =  if gameState[:obsBot] < 1 do
      get_time_distance_to_next_obsBot(gameState, bluePrint) + bluePrint[:geoBot][:obs]
    else
      Enum.max([(bluePrint[:geoBot][:obs] - gameState[:obs]) / (gameState[:obsBot] + 1), 0])
    end

    # IO.inspect("obsNeeded for geo #{obsNeeded}")

    oreNeeded + obsNeeded
  end

  # bfs
  def simulateGame(gameStates, bluePrint, depth) do
    IO.inspect("sim depth #{depth}")
    IO.inspect("breadth #{Enum.count(gameStates)}")
    if depth == 31 do
      Enum.map(gameStates, fn gameState ->
        updatedGameState = get_updated_resource_counts(gameState)
        updatedGameState[:geo]
      end)
    else
      # sort the gamestates by first geo count, then something else?
      # if I can define a good heuristic here, I think I can solve p1 at least
      # thoughts - somehow score based on how close we are to the next milestone we need to progress
      # something to do with the chain
      # ie need obs for geo, need clay for obs, need ore for clay

      prunedGameStates = 
        gameStates
        |> Enum.sort_by(fn gameState ->
          {100 - gameState[:geo], 100 - gameState[:geoBot], get_time_distance_to_next_geoBot(gameState, bluePrint), 100000 - ((gameState[:obs] * 6) + (gameState[:clay] * 2) + (gameState[:geo]))}
        end)
        # |> Enum.reverse()
        |> Enum.uniq()
        |> Enum.take(100000)

      # if (depth === 18) do
      #   IO.inspect("--------------------------------")
      #   IO.inspect("prunedGameStates")
      #   IO.inspect("--------------------------------")
      #   Enum.take(prunedGameStates, 100) |> Enum.map(fn gameState ->
      #     IO.inspect(gameState)
      #     IO.inspect({100 - gameState[:geo], 100 - gameState[:geoBot], get_time_distance_to_next_geoBot(gameState, bluePrint), 100000 - ((gameState[:obs] * 6) + (gameState[:clay] * 2) + (gameState[:geo]))})
      #   end)
      #   throw "test"
      # end

      IO.inspect("debug")
      IO.inspect(get_time_distance_to_next_geoBot(Enum.at(prunedGameStates, 0), bluePrint))
      IO.inspect(Enum.at(prunedGameStates, 0))

      newGameStates = Enum.flat_map(prunedGameStates, fn gameState ->
        possibleActions = get_possible_actions(gameState, bluePrint) 
          |> Enum.filter(fn {key, value} -> value == true end) 
          |> Enum.map(fn {key, value} -> key end)

        updatedGameState = get_updated_resource_counts(gameState)

        Enum.map(possibleActions, fn action ->
          apply_action(updatedGameState, bluePrint, action)
        end)
      end)

      simulateGame(newGameStates, bluePrint, depth + 1)
    end
  end

  # some initial thoughts reading the problem
  # this swarm building thing feels exponential
  # feels like maybe a pathfinding problem where the paths are actions you take
  # idea of getting "possible actions" each turn
  # then filtering down to "useful actions" - such as not building a robot for a resource you won't have enough of by end of game to use
  # it also feels like there might just be a mathematical function, some random thing like 
  # (clayBot.ore * geoBot.ore * oreBot.ore ...etc) to the power of turns or something would equal the score
  # also predicting right now part 2 is going to ask for a lot more turns? haha
  # it also feels like there's some formula for optimal play here
  def main do
    input = get_input()

    bluePrints = parse_input(input) |> Enum.take(3)

    gameStateInit = %{
      :ore => 0,
      :clay => 0,
      :obs => 0,
      :geo => 0,
      :oreBot => 1,
      :clayBot => 0,
      :obsBot => 0,
      :geoBot => 0
    }

    qualityScores = Enum.map(bluePrints, fn bluePrint ->
      IO.inspect(bluePrint)

      # IO.inspect(get_time_distance_to_next_geoBot(gameStateInit, bluePrint))
  
      gameResults = simulateGame([gameStateInit], bluePrint, 0)
      IO.inspect("gameResults")
      IO.inspect(Enum.max(gameResults))


    end)
    
    IO.inspect(qualityScores, charlists: :as_lists)

    Enum.reduce(qualityScores, 1, fn score, acc ->
      acc * score
    end)

  end
end

IO.inspect(Day19.main())
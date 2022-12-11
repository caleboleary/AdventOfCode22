defmodule Day11 do
  def get_input do
    # File.read!("./day11/day11testinput.txt")
    File.read!("./day11/day11input.txt")
  end

  def parse_input fileContents do

    fileContents
        |> String.split("\n\n")
        |> Enum.map(fn monkeyStr ->
            split = String.split(monkeyStr, "\n")

            %{
                id: Enum.at(split, 0) |> String.split(" ") |> Enum.at(1) |> String.replace(":", ""),
                items:
                    Enum.at(split, 1)
                    |> String.split("items: ", trim: true)
                    |> Enum.at(1)
                    |> String.split(", "),
                op: %{
                    operation: Enum.at(split, 2) |> String.split(" ", trim: true) |> Enum.at(4),
                    left:  Enum.at(split, 2) |> String.split(" ", trim: true) |> Enum.at(3),
                    right:  Enum.at(split, 2) |> String.split(" ", trim: true) |> Enum.at(5),
                    action: %{
                    t: Enum.at(split, 4) |> String.slice(-1, 1),
                    f: Enum.at(split, 5) |> String.slice(-1, 1)
                    }
                },
                divisbleBy: Enum.at(split, 3)
                    |> String.split("by ", trim: true)
                    |> Enum.at(1)
                    |> String.to_integer(),
                destinationLog: [],
                inspectionLog: 0
            }
        end)
  end


  def main do
    input = get_input()
    monkeys = parse_input(input)

    roundStates = Enum.reduce(1..20, [monkeys], fn _i, acc ->
        lastRoundState = Enum.at(acc, -1)
        # IO.inspect(lastRoundState)
        newRoundStates = Enum.reduce(lastRoundState, [lastRoundState], fn monkey, roundAcc ->

            inspections = length(Enum.find(Enum.at(roundAcc, -1), fn x -> x.id === monkey.id end).items)
            # IO.inspect("#{monkey.id} has #{inspections} items")

            destinations = Enum.map(Enum.find(Enum.at(roundAcc, -1) |> Enum.map(fn r -> %{r | destinationLog: []} end), fn x -> x.id === monkey.id end).items, fn item ->
                cond do
                    monkey.op.operation === "*" -> String.to_integer(String.replace(monkey.op.left, "old", item)) * String.to_integer(String.replace(monkey.op.right, "old", item))
                    monkey.op.operation === "+" -> String.to_integer(String.replace(monkey.op.left, "old", item)) + String.to_integer(String.replace(monkey.op.right, "old", item))
                end
            end) 
            |> Enum.map(fn increasedItems ->
                trunc(increasedItems / 3)
            end)
            |> Enum.map(fn dividedItems ->
                if rem(dividedItems, monkey.divisbleBy) === 0 do
                    [monkey.op.action.t, dividedItems]
                else
                    [monkey.op.action.f, dividedItems]
                end
            end)
            # IO.inspect(destinations)

            roundAcc ++ [Enum.at(roundAcc, -1)
                |> Enum.map(fn m ->
                    cond do
                        m.id === monkey.id -> 
                            %{
                                m | items: [], destinationLog: destinations, inspectionLog: inspections
                            }
                        m.id === monkey.op.action.t or m.id === monkey.op.action.f -> 
                            %{
                                m | items: m.items ++ (Enum.filter(destinations, fn d -> Enum.at(d, 0) === m.id end) |> Enum.map(fn d -> "#{Enum.at(d, 1)}" end))
                            }
                        true -> m
                    end
                end)]
                # |> IO.inspect()  # this one seems right??

        end)
        acc ++ newRoundStates
        
    end)
    # |> IO.inspect()

    passCounts = roundStates
    # |> Enum.slice(0..-5)
    |> Enum.with_index()
    #filter to every 5th round
    |> Enum.filter(fn {_, i} -> rem(i, length(monkeys) + 1) === 0 end)
    |> Enum.map(fn {roundResult, i} ->
    #     IO.inspect(i)
        # Enum.reduce(roundResult, [], fn monkey, acc ->
        #     acc ++ monkey.destinationLog
        # end) |> IO.inspect()
        roundResult
        |> Enum.reduce([], fn monkey, acc ->
           acc ++ List.duplicate(monkey.id, monkey.inspectionLog)
        end)
    end)
    |> Enum.concat()
    |> IO.inspect()

    IO.inspect(Enum.at(roundStates, -1))
    
    Enum.map(0..length(monkeys) - 1, fn i ->
        Enum.filter(passCounts, fn x -> x === "#{i}" end) |> length()
    end)
    |> Enum.with_index()
    |> Enum.map(fn {count, i} -> 
         "#{i}: #{count}"
        # "#{i}: #{count + (Enum.at(monkeys, i).items |> length())}"
    end)
    |> IO.inspect()
    
    counts = Enum.map(0..length(monkeys) - 1, fn i ->
        Enum.filter(passCounts, fn x -> x === "#{i}" end) |> length()
    end)
    |> Enum.sort()

    Enum.at(counts, -1) * Enum.at(counts, -2)
    

  end
end

IO.inspect(Day11.main())
# Day11.main()
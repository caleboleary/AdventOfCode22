defmodule Day3 do

    def alphabet do "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" end

    def get_input do
        data = File.read!("./day3/day3input.txt")
        sacks = String.split(data, "\n")
        subPouches = Enum.map(sacks, fn sack -> 
            Tuple.to_list(String.split_at(sack, trunc(String.length(sack) / 2)))
        end)
        subPouches
    end

    def find_duplicate_chars(firstPouch, secondPouch) do
        firstPouchSplit = String.split(String.trim(firstPouch), "", trim: true)
        secondPouchSplit = String.split(String.trim(secondPouch), "", trim: true)
        dupes = Enum.reduce(firstPouchSplit, %{}, fn char, acc ->
            if Enum.member?(secondPouchSplit, char) do
                Map.put(acc, char, true)
            else
                acc
            end
        end)
        Map.keys(dupes)
    end

    def indexOf(string, substr) do
        split = String.split(string, substr)
        if length(split) == 1 do
            -1
        else
            String.length(split |> List.first) + 1
        end
    end

    def main do 
        data = get_input()
        dupesLists = Enum.map(data, fn sack ->
            find_duplicate_chars(Enum.at(sack, 0), Enum.at(sack, 1))
        end)
        fullDupeList = Enum.reduce(dupesLists, [], fn dupe, acc ->
            acc ++ dupe
        end) |> Enum.map(fn char -> indexOf(alphabet(), char) end)

        fullDupeList |> Enum.reduce(0, fn dupe, acc -> acc + dupe end)
    end

end

IO.inspect(Day3.main)
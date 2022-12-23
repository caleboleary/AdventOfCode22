defmodule Day3 do

    def alphabet do "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" end

    def get_input do
        data = File.read!("./day3/day3input.txt")
        String.split(data, "\n")
    end

    def find_duplicate_chars(bag1, bag2, bag3) do
        bag1Split = String.split(String.trim(bag1), "", trim: true)
        bag2Split = String.split(String.trim(bag2), "", trim: true)
        bag3Split = String.split(String.trim(bag3), "", trim: true)
        dupes = Enum.reduce(bag1Split, %{}, fn char, acc ->
            if Enum.member?(bag2Split, char) and Enum.member?(bag3Split, char) do
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
        groups = Enum.chunk_every(data, 3)
        dupesLists = Enum.map(groups, fn group ->
            find_duplicate_chars(Enum.at(group, 0), Enum.at(group, 1), Enum.at(group, 2))
        end)
        fullDupeList = Enum.reduce(dupesLists, [], fn dupe, acc ->
            acc ++ dupe
        end) |> Enum.map(fn char -> indexOf(alphabet(), char) end)
        

        fullDupeList |> Enum.reduce(0, fn dupe, acc -> acc + dupe end)
    end

end

IO.inspect(Day3.main)
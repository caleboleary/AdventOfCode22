IO.puts('day 1')

data = File.read!("./day1input.txt")
elvesInventory = String.split(data, "\n\n")
elvesInventorySplit = Enum.map(elvesInventory, fn inventory -> String.split(inventory, "\n") end)

elvesInventoryCalorieTotal =
  Enum.map(elvesInventorySplit, fn inventory ->
    Enum.reduce(inventory, 0, fn currCals, invAcc -> invAcc + String.to_integer(currCals) end)
  end)

elvesInventoryCalorieTotalSorted = Enum.sort(elvesInventoryCalorieTotal, fn a, b -> b < a end)

#pt 1

# mostCals = Enum.at(elvesInventoryCalorieTotalSorted, 0)

#pt 2

top3Cals = Enum.reduce(Enum.take(elvesInventoryCalorieTotalSorted, 3), 0, fn cals, acc -> acc + cals end)

IO.inspect(top3Cals)
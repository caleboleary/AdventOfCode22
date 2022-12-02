


#define module
defmodule Day2 do

    def evaluateRound(me, enemy) do

        enemyPlays = %{rock: 'A', paper: 'B', scissors: 'C'}
        myPlays = %{rock: 'X', paper: 'Y', scissors: 'Z'}

        playScores = %{
            X: 1,
            Y: 2,
            Z: 3,
        }

        outcomeScores = %{
            win: 6,
            lose: 0,
            draw: 3
        }

        outcomeTable = %{
            AX: :draw,
            AY: :win,
            AZ: :lose,
            BX: :lose,
            BY: :draw,
            BZ: :win,
            CX: :win,
            CY: :lose,
            CZ: :draw
        }

        myScore = playScores[String.to_atom(me)]
        outcome = outcomeTable[String.to_atom(enemy <> me)]
        IO.inspect(outcome)
        outcomeScore = outcomeScores[outcome]
        

        myScore + outcomeScore
    end

    def playGame() do
    
        

        data = File.read!("./day2/day2input.txt")
        stratGuide = String.split(data, "\n")

        roundScores = Enum.map(stratGuide, fn strat ->
            strat = String.split(strat, " ")
            enemyPlay = Enum.at(strat, 0)
            myPlay = Enum.at(strat, 1)
            Day2.evaluateRound(myPlay, enemyPlay)
        end)

        IO.inspect(roundScores) 

        roundScoresTotal = Enum.reduce(roundScores, 0, fn score, acc -> acc + score end)

        IO.inspect(roundScoresTotal)
    end

end

Day2.playGame()

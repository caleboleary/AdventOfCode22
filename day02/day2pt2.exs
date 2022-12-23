


#define module
defmodule Day2 do

    def evaluateRound(desiredOutcome, enemy) do

        enemyPlays = %{rock: 'A', paper: 'B', scissors: 'C'}
        myPlays = %{rock: 'X', paper: 'Y', scissors: 'Z'}

        playScores = %{
            rock: 1,
            paper: 2,
            scissors: 3,
        }

        desiredOutcomes = %{
            X: :lose,
            Y: :draw,
            Z: :win
        }

        outcomeScores = %{
            win: 6,
            lose: 0,
            draw: 3
        }

        outcomeTable = %{
            Adraw: :rock,
            Awin: :paper,
            Alose: :scissors,
            Bdraw: :paper,
            Bwin: :scissors,
            Blose: :rock,
            Cdraw: :scissors,
            Cwin: :rock,
            Close: :paper
        }

        # myScore = playScores[String.to_atom(me)]
        # outcome = outcomeTable[String.to_atom(enemy <> me)]
        # IO.inspect(outcome)
        # outcomeScore = outcomeScores[outcome]
        

        # myScore + outcomeScore


        desiredOutcomeAtom = desiredOutcomes[String.to_atom(desiredOutcome)]
        IO.inspect(desiredOutcomeAtom)
        outcomeIndex = enemy <> Atom.to_string(desiredOutcomeAtom)
        IO.inspect(outcomeIndex)
        thaPlay = outcomeTable[String.to_atom(outcomeIndex)]
        IO.inspect(thaPlay)

        myScore = playScores[thaPlay]
        IO.inspect(myScore)
        outcomeScore = outcomeScores[desiredOutcomeAtom]
        IO.inspect(outcomeScore)

        myScore+outcomeScore

        # myPlay = outcomeTable[String.to_atom(enemy <> desiredOutcomes[String.to_atom(desiredOutcome)])]
        # IO.inspect(myPlay)
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

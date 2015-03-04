require_relative 'HumanPlayer'



class GameRunner
    def run(computer)
        puts "please enter a pattern of 4 (repeatable) colors out of (r,g,o,y,b,p) (ie. if (r,p,y,r) then type 'rpyr'):"
        human_input = $stdin.gets.chomp()
        puts "you entered #{human_input}"
        
        hp = HumanPlayer.new(human_input)
        cp = computer.new()

        win_flag = false
        try_count = 0
        while (not win_flag) && (try_count < 10)
            puts ""
            puts "try #{try_count}"
            guess = cp.smart_guess()
            puts "computer guesses #{guess}"
            feedback = hp.check_guess(guess)
            puts "human replies #{feedback}"
            cp.process_feedback(feedback)
            if feedback == [0,4]
                puts "Computer won:  correct guess #{guess}"
                win_flag = true
                break
            end
            try_count += 1
        end

        if win_flag == false
            puts "You beat the computer!"
        end
    end
end


class HumanPlayer
    def initialize(input_pattern)
        @pattern = input_pattern
        @pattern_len = @pattern.length()
    end

    def change_pattern(new_pattern)
        @pattern = new_pattern
        @pattern_len = @pattern.length()
    end

    def check_guess(guess)
        guess_dup = guess.dup
        pattern_dup = @pattern.dup
        num_correct_both = check_correct_color_and_position(pattern_dup, guess_dup)
        num_correct_colors_only = check_correct_color_only(pattern_dup, guess_dup)
        return [num_correct_colors_only, num_correct_both]
    end

    def check_correct_color_and_position(pattern_dup, guess_dup)
        num_correct_both = 0
        (0...@pattern_len).each do |i|
            if guess_dup[i] == @pattern[i]
                num_correct_both += 1
                pattern_dup[i] = "?"
                guess_dup[i] = "_"
            end    
        end 
        return num_correct_both
    end

    def check_correct_color_only(pattern_dup, guess_dup)
        num_correct_colors_only = 0
        guess_dup.split("").each_with_index do |c, i|
            if c == "_"
                next
            end
            pind = pattern_dup.index(c)
            if !pind.nil?
                pattern_dup[pind] = "?"
                num_correct_colors_only += 1
            end
        end
        return num_correct_colors_only
    end
end


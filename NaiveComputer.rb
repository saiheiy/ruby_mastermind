require 'set'

class NaiveComputer
    def initialize()
        @num_positions = 4
        @colors = "rgoybp".freeze()
        @num_colors = @colors.length()
        @cur_color_ind = 0
        @unsolved_colors = Hash[@colors.split(//).map() {|x| [x, {:count=>0, :activated=>false}]}]
        @solved_pegs = [nil]*@num_positions
        @num_solved_pegs = 0
        @disqualified_colors_in_position = (1..@num_positions).map {Set.new}
        @cur_unsolved_peg = {:color=>nil, :position=>nil}
    end

    def smart_guess()
        guess = _populate_initial_base_guess()
        guess = _populate_solved_pegs_in_guess(guess)
        guess = _populate_unsolved_peg_candidate_in_guess(guess)
        return guess
    end

    def process_feedback(feedback)
        num_right_col, num_right_both = feedback
        num_right_both_added = num_right_both - @num_solved_pegs

        num_col_gained = _get_num_colors_gained(num_right_col, num_right_both_added)
        _update_unsolved_colors(num_col_gained)
        _check_cur_unsolved_peg(num_right_both_added, num_col_gained)
        
        #short-circuiting
        while _short_circuit_position() | _short_circuit_color() | _update_disqualified_colors_in_position()
        end
    end

###############  PRIVATE METHODS ###################################################    

    def _populate_initial_base_guess()
        guess = "_"*@num_positions 
        if @cur_color_ind < @num_colors
            cur_color = @colors[@cur_color_ind]
            guess = cur_color*@num_positions
        else
            guess = _populate_guess_with_disqualified_colors(guess)
        end
        return guess
    end

    def _populate_guess_with_disqualified_colors(guess)
        @disqualified_colors_in_position.each_with_index do |csi, i|
            if !@solved_pegs[i].nil?
                next
            end
            if csi.size() == 0
                raise "#{__FILE__}:#{__LINE__}: position has no disqualified colors --> this shouldn't happen, maybe bug in HumanPlayer"
            else
                guess[i] = csi.to_a()[0]
            end
        end
        return guess
    end

    def _populate_solved_pegs_in_guess(guess)
        @solved_pegs.each_with_index do |sci, i|
            if !sci.nil?()
                guess[i] = sci
            end
        end 
        return guess
    end

    def _populate_unsolved_peg_candidate_in_guess(guess)
        if @cur_unsolved_peg[:color].nil?
            _draw_from_unsolved_colors()
        end

        if !@cur_unsolved_peg[:color].nil?
            @disqualified_colors_in_position.each_with_index do |dcs, i|
                if !dcs.include?(@cur_unsolved_peg[:color])
                    @cur_unsolved_peg[:position] = i
                    guess[@cur_unsolved_peg[:position]] = @cur_unsolved_peg[:color]
                    break
                end
            end
        end
        return guess
    end

    def _draw_from_unsolved_colors()
        #cur_unsolved_color should be nil here
        if !@cur_unsolved_peg[:color].nil?
            raise "#{__FILE__}:#{__LINE__}: trying to draw new color when current unsolved_peg is still occupied"
        end
        #drawing color with the highest unsolved_count (to maximize chance of solving on next try)
        max_count = 0
        max_col = nil
        @unsolved_colors.each do |col, hashi|
            if hashi[:count] > max_count 
                max_col = col
                max_count = hashi[:count]
            end
        end
        if !max_col.nil?()
            @cur_unsolved_peg[:color] = max_col
        end
    end
    
    def _get_num_colors_gained(num_right_col, num_right_both_added)
        if @cur_unsolved_peg[:color].nil?
            num_col_gained = num_right_col + num_right_both_added 
        else
            #subtract an additional 1 for the currently loaded color
            num_col_gained = num_right_col + num_right_both_added - 1 
        end 
        return num_col_gained
    end

    def _update_unsolved_colors(num_col_gained)
        if @cur_color_ind < @num_colors
            @unsolved_colors[@colors[@cur_color_ind]][:count] = num_col_gained
            @unsolved_colors[@colors[@cur_color_ind]][:activated] = true
            @cur_color_ind += 1
        end
    end

    def _check_cur_unsolved_peg(num_right_both_added, num_col_gained)
        #check if cur_unsolved_color is solved
        if num_right_both_added - num_col_gained == 1
            _record_peg_solved(@cur_unsolved_peg)
            _reset_cur_unsolved_peg()
        elsif !@cur_unsolved_peg[:color].nil?
            @disqualified_colors_in_position[@cur_unsolved_peg[:position]].add(@cur_unsolved_peg[:color])
            @cur_unsolved_peg[:position] += 1
        end
    end

    def _record_peg_solved(peg_hash)
        @solved_pegs[peg_hash[:position]] = peg_hash[:color]
        @num_solved_pegs += 1
        @colors.split("").each do |c|
            @disqualified_colors_in_position[peg_hash[:position]].add(c)
        end
        @unsolved_colors[peg_hash[:color]][:count] -= 1
    end

    def _reset_cur_unsolved_peg()
        @cur_unsolved_peg[:color] = nil
        @cur_unsolved_peg[:position] = nil
    end

    def _short_circuit_position()
        #checks if (current_color) is disqualified in 3 of the 4 positions, if so then we force
        #returns true if successful
        flag = false
        num_disqualified_positions = 0
        position_candidate = nil
        @disqualified_colors_in_position.each_with_index do |csi, i|
            if csi.include?(@cur_unsolved_peg[:color])
                num_disqualified_positions += 1
            else
                position_candidate = i
            end
        end
        if num_disqualified_positions == (@num_positions-1)
            _record_peg_solved({:color=>@cur_unsolved_peg[:color], :position=>position_candidate})
            _reset_cur_unsolved_peg()
            flag = true
        end        
    end

    def _short_circuit_color()
        changed_flag = false
        @disqualified_colors_in_position.each_with_index do |csi, i|
            if !@solved_pegs[i].nil?
                next
            end

            if csi.size() == (@num_colors - 1)
                remaining_color = _find_remaining_color(csi)
                _record_peg_solved({:color=>remaining_color, :position=>i})
                if @cur_unsolved_peg[:color] == remaining_color
                    _reset_cur_unsolved_peg()
                end
                changed_flag = true
            elsif csi.size() < (@num_colors - 1)
            else
                raise "#{__FILE__}:#{__LINE__}: size of disqualified colors in position should not exceed 5"
            end
        end
        return changed_flag
    end

    def _find_remaining_color(set_of_disqualified_colors)
        remaining_color = nil
        @colors.split("").each do |c|
            if !set_of_disqualified_colors.member?(c)
                remaining_color = c
                break
            end
        end
        return remaining_color
    end

    def _update_disqualified_colors_in_position()
        changed_flag = false
        @colors.split("").each do |c|
            if @unsolved_colors[c][:activated] && @unsolved_colors[c][:count] == 0
                @disqualified_colors_in_position.each_with_index do |csi, i|
                    if !csi.include?(c)
                        changed_flag = true
                        csi.add(c)
                    end
                end
            end
        end
        return changed_flag
    end
end


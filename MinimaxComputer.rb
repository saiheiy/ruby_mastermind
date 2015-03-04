require 'set'
#require 'profile'

def build_color_count_hash(pset, colors_array)
    puts "build_color_count_hash called"
    output = Hash.new(0)
    pset.each do |p|
        output[p] = colors_array.map {|ci| p.count(ci)}
    end
    return output
end

class MinimaxComputer
    @@colors = "rgoybp"
    @@colors_array = @@colors.split("")
    @@all_permutations = @@colors_array.repeated_permutation(4).map {|v| v.join("")} 
    @@color_count_hash = build_color_count_hash(@@all_permutations, @@colors_array)
    @@response_hash = Hash.new
    @@num_colors = @@colors.length
    @@guess_size = 4
    @@color_range = (0...@@num_colors)
    @@guess_range = (0...@@guess_size)
    @@gtable = Hash.new(0)
    
     
    def initialize()
        @candidates_set = @@all_permutations.to_set
        @guess = "rroo"
        @minG_hash = Hash.new
        @maxmin_guess = nil
    end

    def smart_guess()
        return @guess
    end

    def process_feedback(feedback)
        _prune_candidates_set(feedback)
        _update_minG_per_guess()
        _update_maxmin_guess()
    end

    def _prune_candidates_set(feedback)
        num_col_right, num_both_right = feedback
        total_col_right = num_col_right + num_both_right
        #guess_counts = @@colors_array.map {|c| @guess.count(c)}
        guess_dup = @guess.dup
        #puts "before pruning %s"%(@candidates_set.size) 
        @candidates_set.dup.each do |p|
            response = _get_response_build_if_not_exist(p,guess_dup)

            if response != feedback
                @candidates_set.delete(p)
            end


            #if (_calc_num_both_right_with_guess(p, @guess) == num_both_right) && (_calc_total_colors_right_with_guess(@@color_count_hash[p], @@color_count_hash[@guess]) == total_col_right)
                ##permutation remains
            #else
                #@candidates_set.delete(p)
            #end
        end
        #puts "after pruning %s"%(@candidates_set.size) 
        #puts @candidates_set.to_a[0]
    end

    def _get_response_build_if_not_exist(p, g)
        response_key = p+g
        if @@response_hash.include?(response_key)
            return @@response_hash[response_key]
        else
            num_both_right = _calc_num_both_right_with_guess(p, g)
            num_col_right = _calc_total_colors_right_with_guess(@@color_count_hash[p], @@color_count_hash[g])
            response = [num_col_right-num_both_right, num_both_right]
            @@response_hash[response_key] = response
            response_key_rev = g+p
            @@response_hash[response_key_rev] = response
            return response
        end
    end

    def _calc_num_both_right_with_guess(p, g)
        return @@guess_range.count {|ii| p[ii] == g[ii]}
    end

    def _calc_total_colors_right_with_guess(pcounts, gcounts)
        return @@color_range.reduce(0) {|y, ri| y + ([pcounts[ri], gcounts[ri]].min)}
    end

    def _update_minG_per_guess()
        maxmin_val = 0
        @minmax_gtable_val = 1296
        @maxmin_guess = nil
        @@all_permutations.each do |g|
            v = _calc_minG(g)
            if v > maxmin_val
                maxmin_val = v
                @maxmin_guess = g
            end
        end
    end

    def _calc_minG(g)
        @@gtable.clear()
        #gtable = Hash.new(0)
        #gcounts = @@colors_array.map {|ci| g.count(ci)}
        @candidates_set.each do |cand|
            response = _get_response_build_if_not_exist(cand, g) 
            key = response[0]*10 + response[1]
            @@gtable[key] += 1
            if @@gtable[key] >= @minmax_gtable_val
                return 0
            end
        end
        if @@gtable.values.max < @minmax_gtable_val
            @minmax_gtable_val = @@gtable.values.max
        end

        return @candidates_set.size - @@gtable.values.max
    end

    def _update_maxmin_guess()
        if @candidates_set.size == 1
            @guess = @candidates_set.to_a[0]
        else
            @guess = @maxmin_guess
        end
    end
end

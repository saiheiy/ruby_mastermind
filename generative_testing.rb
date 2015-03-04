require_relative 'HumanPlayer'

if ARGV.length == 0 || ARGV[0] == 'NaiveComputer'
    require_relative 'NaiveComputer'
    computer = NaiveComputer
elsif ARGV[0] == 'MinimaxComputer'
    require_relative 'MinimaxComputer'
    computer = MinimaxComputer
end


colors = "rgoybp"
all_permutations = colors.split("").repeated_permutation(4).map {|v| v.join("")}
total_cases = all_permutations.length
puts "total number of cases: #{total_cases}"
num_correct = 0
cp = computer.new()
all_permutations.each do |p|
    
    hp = HumanPlayer.new(p)
    cp.send(:initialize)
    win_flag = false
    try_count = 0
    while (not win_flag) && (try_count < 10)
        guess = cp.smart_guess()
        feedback = hp.check_guess(guess)
        cp.process_feedback(feedback)
        if feedback == [0,4]
            win_flag = true
            break
        end
        try_count += 1
    end
    if win_flag
        num_correct += 1
    else
        puts "failed case ${p}"
    end
end

puts "total number correct: #{num_correct}"

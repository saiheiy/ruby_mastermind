require_relative 'GameRunner'

if ARGV.length == 0 || ARGV[0] == 'NaiveComputer'
    require_relative 'NaiveComputer'
    computer = NaiveComputer
elsif ARGV[0] == 'MinimaxComputer'
    require_relative 'MinimaxComputer'
    computer = MinimaxComputer
end

gr = GameRunner.new()
gr.run(computer)

require 'pry'

## THINK ABOUT SERIALIZING EACH MATCH - COULD LOOK UP HISTORY?

class Mastermind
    attr_accessor :turn_count

    def initialize
        @red = "\e[1m\e[31m*\e[0m\e[22m"
        @blue = "\e[1m\e[34m*\e[0m\e[22m"
        @green = "\e[1m\e[32m*\e[0m\e[22m"
        @yellow = "\e[1m\e[33m*\e[0m\e[22m"
        @pink = "\e[1m\e[35m*\e[0m\e[22m"
        @color_but_space = "\e[1m\e[44m  \e[0m\e[22m"
        @color_and_space = "\e[1m\e[42m  \e[0m\e[22m"

        @gap = "  "
        @choices = [@red, @blue, @green, @yellow, @pink]
        @code = []
        @turn_count = 1
        @start_phrase = "The code has been set."
        @instruct = "please choose one of five options: red, blue, green, yellow, or pink"

        @submitted_guess = []
        @guess_list = []

        @clue = Array.new(5, @gap)
        @clue_list = []

        @display_list = [@gap]
    end

    def pick_colors
        puts @instruct
        color_set = []
        i = 1
        while i <= 5
            puts "choose color # #{i}:"
            color = gets.chomp.to_s.downcase
            clear_line(2)

            case color
            when "red"
                color_set.push(@red)
            when "blue"
                color_set.push(@blue)
            when "green"
                color_set.push(@green)
            when "yellow"
                color_set.push(@yellow)
            when "pink"
                color_set.push(@pink)
            else
                puts @instruct
                redo
            end
            i += 1
        end
        return color_set
    end

    def enter_guess
        @guess_list << @submitted_guess
        guess = "#{self.turn_count}. #{@submitted_guess.join("#{@gap} ")}"
        display_turn(guess)
    end

    def enter_clue
        @clue_list << @clue
        guess = "#{self.turn_count}. #{@submitted_guess.join("#{@gap} ")}     | #{@clue.join(' | ')} |"
        
        if self.turn_count == 1 
            clear_line(3)
            puts
        else
            clear_line(3)
        end

        display_turn(guess)
    end

    def game_over?
        @submitted_guess == @code ? true : false
    end

    def clear
        if game_over? == false
            @submitted_guess = []
            @clue = Array.new(5, @gap)
            @guess_list << @gap
        end
    end

    def show_code
       puts "The Code: #{@code.join("#{@gap} ")}"
    end
    
    def clear_line(number_of_lines)
        print "\e[A\e[2K" * number_of_lines
    end

    def generate_five_random
        five_colors = []
        5.times do
            five_colors.push(@choices[rand(5)])
        end
        return five_colors
    end

    def display_turn(guess)
        @display_list[self.turn_count - 1] = guess
        puts puts @display_list.last
    end
end

class MastermindHuman < Mastermind
    def initialize
        super
        @winning_statement = [
            "Congrats, you did it! You're pretty smart.",
            "Wow, how did you do that so fast? It only took you #{self.turn_count} tries!}",
            "OK, ok, why don't you give someone else a turn hotshot...",
            "You're not as dumb as you look.",
            "Maybe try a harder difficulty? just sayin..."
        ]
    end
    
    def play
        cpu_generate_code
        puts @start_phrase
        sleep 0.5
        while game_over? == false
            sleep 1.5
            pick_colors
            check_clue_clear
            self.turn_count += 1
        end
        puts @winning_statement.shuffle.first
        puts "the code was:"
        show_code
        sleep 2

        puts "Want to play again? yes/no"
        play_again = gets.chomp.downcase
        if play_again == "yes"
            initialize
            self.play
        else
            puts "Goodbye!"
        end
    end

    def cpu_generate_code
        @code = generate_five_random
        @code.join("#{@gap} ")
    end

    def pick_colors
        puts @instruct
        i = 1
        while i <= 5
            puts "choose color # #{i}:"
            color = gets.chomp.to_s.downcase
            clear_line(2)
            
            case color
            when "red"
                @submitted_guess.push(@red)
                clear_line(2) if i != 1
                enter_guess
            when "blue"
                @submitted_guess.push(@blue)
                clear_line(2) if i != 1
                enter_guess
            when "green"
                @submitted_guess.push(@green)
                clear_line(2) if i != 1
                enter_guess
            when "yellow"
                @submitted_guess.push(@yellow)
                clear_line(2) if i != 1
                enter_guess
            when "pink"
                @submitted_guess.push(@pink)
                clear_line(2) if i != 1
                enter_guess
            else
                puts instruct
                redo
            end
            i += 1
        end
        @submitted_guess
    end

    def cpu_check_code
        code_color_count = {}
        @code.each do |color|
            code_color_count[color] = @code.count(color)
        end
        
        #### SET THE GREENS FIRST ####
        @submitted_guess.each_with_index do |my_color, index|
            if my_color == @code[index]
                @clue[index] = @color_and_space
                code_color_count[my_color] -= 1
                code_color_count.select! { |key, value| value > 0 }
            end
        end

        #### SET THE BLUES AFTER ####
        @submitted_guess.each_with_index do |my_color, index|
            if @clue[index] == @gap && code_color_count.keys.include?(my_color)
                @clue[index] = @color_but_space
                code_color_count[my_color] -= 1
                code_color_count.select! { |key, value| value > 0 }
            end
        end
    end

    def check_clue_clear
        cpu_check_code
        enter_clue
        clear
    end


end

class MastermindCpu < Mastermind
    def initialize
        super
        @clue = []
        @winning_statement = [
            "You're not even making me work...",
            "WOW... it only took me #{self.turn_count} tries!",
            "OK, ok, why don't you give someone else a turn hotshot...",
            "Good code... tricky... you almost had me.",
            "Maybe try a harder difficulty? just sayin..."
        ]
    end

    def play
        human_set_code
        puts @start_phrase

        while game_over? == false
            sleep 1
            @submitted_guess = Array.new(5, @gap)
            cpu_pick_colors
            enter_guess
            human_check_code
            enter_clue
            self.turn_count += 1
        end

    end

    def human_set_code
        puts "You must set the new code."
        @code = pick_colors
    end

    def cpu_pick_colors
        # Look at the clue and only fill the indexes that are not green those that are 
        # green use the same color in that index
        # if blue clue use those colors first, but put them in different indexes
        # if a color is matched with @gap in the clue, don't use that color anymore, unless
        # there is a green clue for said color.
        if @turn_count == 1 || @clue.all?(@gap)
           @submitted_guess = generate_five_random
        else
            cpu_pick_green
            binding.pry
            cpu_pick_blues
            # cpu_pick_gap
            
        end
        @submitted_guess
    end

    def cpu_pick_green
        #if the clue_list.last has a green square then place the same color in the 
        #corresponding index of the last_guess in the current (working) submitted_guess.
        if @clue.any?(@color_and_space)
           @clue.each_with_index do |clue, index|
                if clue == @color_and_space
                    @submitted_guess[index] = @guess_list.last[index]
                end
            end
        end
        @submitted_guess
    end

    def cpu_pick_blues
        return if @clue.none?(@color_but_space)

        blue_colors = []
        
        @clue.each_with_index do |clue, index|
            if clue == @color_but_space
                blue_colors << @guess_list.last[index]
            end
        end
        binding.pry

        indexes = [0, 1, 2, 3, 4]

        @submitted_guess.each_with_index do |position, index|
            if position != @gap
                indexes.delete(index)
            end
        end
        
        binding.pry

        blue_colors.each do |color|
            @guess_list.each do |guess|
                guess.each_with_index do |choice, index|
                    if choice == color
                        indexes.delete(index)
                    else
                        next
                    end
                end
            end
            binding.pry
            new_spot = indexes.first
            binding.pry
            @submitted_guess[new_spot] = color
            binding.pry
        end
        @submitted_guess
    end

    def cpu_pick_gap
        #look though the clue - any @gaps in the clue mean the color is not used
        #take the color from the corresponding index in the latest guess and add it to the "no_use" list
        #take these colors away from the working_colors list. fill in the @gap's in the current (working)
        #submitted guess with random colors from working_colors
        no_use = []
        @clue.each_with_index do |position, index|
            if position != @gap
                next
            else
               no_use << @guess_list.last[index]
            end
        end
        binding.pry
        working_colors = @choices - no_use
        binding.pry
        @submitted_guess.map! do |position|
            if position != @gap
                next
            else
                position = working_colors[rand(working_colors.length + 1)]
            end
        end
    end

    def human_check_code
        instruct = ["Please place put 'GREEN' if the color is correct and in the correct spot.",
        "'BLUE' if the color is in the code, but not in its current position",
        "'WRONG' if the color is not in the code"]
        puts instruct
        @clue = []
        i = 1
        while i <= 5
            puts "give clue ##{i}:"
            clue = gets.chomp.downcase
            clear_line(2)

            case clue
            when "green"
                @clue << @color_and_space
            when "blue"
                @clue << @color_but_space
            when "wrong"
                @clue << @gap
            else
                puts instruct
                redo
            end
            i += 1
        end
        @clue
    end

    def clear
        if game_over? == false
            super
            @clue = []
        end
    end

    def display_turn(guess)
        @display_list[self.turn_count - 1] = guess
        if self.turn_count == 1
            show_code
            puts
        end
        puts puts @display_list.last
    end
end

# human_play = MastermindHuman.new
# computer_play = MastermindCpu.new

# puts "Would you like to 'SET' or 'GUESS' the code?"
# response = gets.chomp.downcase
# if response == "guess"
#     human_play.play
# elsif response == "set"
#     computer_play.play
# else
#     puts "No, you have to pick one: guess or set?"
# end



# print "\e[A\e[2K"
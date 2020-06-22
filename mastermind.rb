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
            "Wow, how did you do that so fast?",
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
        show_code
        sleep 2
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
                puts @instruct
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
            "WOW... I'm good!",
            "OK, ok, why don't you give someone else a turn hotshot...",
            "Good code... tricky... you almost had me.",
            "Maybe try a harder difficulty? just sayin..."
        ]
        @no_use_colors = []
    end

    def play
        human_set_code
        puts @start_phrase
        show_code
        puts

        while game_over? == false
            sleep 1.5
            @submitted_guess = Array.new(5, @gap)
            cpu_pick_colors
            enter_guess
            human_check_code
            clear_line(2)
            enter_clue
            self.turn_count += 1
        end
        puts @winning_statement.shuffle.first
        sleep 2
    end

    def human_set_code
        puts "You must set the new code."
        @code = pick_colors
    end

    def cpu_pick_colors
        # If its the frist guess, or there were no clues given, randomly select 5 new clues

        # Look at the clue and only fill the indexes that are not green. Those that are green, use the same color in 
        # @guess_list.last that matches the index of @clue where the green clue was placed.

        # if a blue clue is given use those colors next, but put them in different indexes

        # if a color is matched with @gap in the clue, don't use that color anymore, 
        # unless there is a green clue for said color.

        if @turn_count == 1 || @clue.all?(@gap)
           @submitted_guess = generate_five_random
        else
            cpu_pick_green
            cpu_pick_blues
            cpu_pick_gap
        end
        @submitted_guess
    end

    def cpu_pick_green
        #if the clue has a green square then place the same color from guess_list.last in @submitted_guess which corresponds
        #to the index of @clue where the green square was place.

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

        # loop though @clue and store all the colors identified in the guess_list.last as the right color but wrong position
        blue_colors = []
        @clue.each_with_index do |clue, index|
            if clue == @color_but_space
                blue_colors << @guess_list.last[index]
            end
        end

        # loop through all the colors that are in the code, but in the wrong place
        blue_colors.each do |color|
            #becuse the colors identified by the @color_and_space are already in place, we dont want to write over these
            #remove those indexes as possible positions to place the next "blue_color" clues.
            indexes = [0, 1, 2, 3, 4]
            @submitted_guess.each_with_index do |position, index|
                if position != @gap
                    indexes.delete(index)
                end
            end

            #look through all guess history
            @guess_list.each do |guess|
                #look at each choice within each guess
                guess.each_with_index do |choice, index|
                    #if the "blue_color" we are looking to place right now has alredy been in this index position, take 
                    #away the option to put it here again, remove the index from the list of possible indexes
                    working_color = ""
                    if choice == color && blue_colors.count(color) == 1
                        indexes.delete(index)
                    elsif choice == color && blue_colors.count(color) > 1 && working_color != color #this needs tweeking
                        indexes.delete(index)
                        working_color = color
                    elsif choice == color && choice == working_color
                        next
                    else
                        next
                    end
                    working_color = ""
                end
            end
            
            #look though the options of index positions in which we can put one of our "blue colors" and place it.
            #after the color has been placed, we need to add its old index position back into the option set for other colors
            #to be placed there
            new_spot = indexes.first
            @submitted_guess[new_spot] = color
            @clue.each_with_index do |clue, index|
                if clue == @color_but_space && index == @guess_list.last.index(color)
                    indexes << index
                else
                    next
                end
            end
        end
        @submitted_guess
    end

    def cpu_pick_gap
        #look though the clue - any @gaps in the clue mean the color is not used (unless it has already been marked @color_and_space)
        #take the color from the corresponding index in the latest guess and add it to the "no_use" list
        #take these colors away from the working_colors list. fill in the @gap's in the current (working)
        #submitted guess with random colors from working_colors (so as not to repeat unnecessary colors)
        no_use = []
        @clue.each_with_index do |position, index|
            if position != @gap
                next
            else
               no_use << @guess_list.last[index]
            end
        end

        @no_use_colors + no_use
        @no_use_colors.uniq!
        working_colors = @choices - @no_use_colors #this considers not only the new colors identified as "wrong" but also from all guesses previous.

        @submitted_guess.each_with_index do |position, index|
            if position == @gap
                @submitted_guess[index] = working_colors[rand(working_colors.length)]
            end
        end
        @submitted_guess
    end

    def human_check_code
        instruct = ["Please put 'GREEN' if the color is correct and in the correct spot.",
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
                puts @instruct
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

    def enter_clue
        @clue_list << @clue
        guess = "#{self.turn_count}. #{@submitted_guess.join("#{@gap} ")}     | #{@clue.join(' | ')} |"
        clear_line(3)
        
        display_turn(guess)
    end
end

human_play = MastermindHuman.new
computer_play = MastermindCpu.new

play_again = "yes"
while play_again == "yes"
    puts "Would you like to 'SET' or 'GUESS' the code?"
    response = gets.chomp.downcase
    if response == "guess"
        human_play.play
    elsif response == "set"
        computer_play.play
    else
        puts "No, you have to pick one: guess or set?"
    end

    puts "Want to play again? yes/no"
    play_again = gets.chomp.downcase
end
puts "Goodbye!"
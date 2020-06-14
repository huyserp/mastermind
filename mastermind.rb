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
        @code = []
        @guess_list = []
        @display_list = [@gap]
        @submitted_guess = []
        @clue = Array.new(5, @gap)
        @choices = [@red, @blue, @green, @yellow, @pink]
        @turn_count = 1
        @winning_statement = [
            "Congrats, you did it! You're pretty smart.",
            "Wow, how did you do that so fast? It only took you #{self.turn_count} tries!}",
            "OK, ok, why don't you give someone else a turn hotshot...",
            "You're not as dumb as you look.",
            "Maybe try a harder difficulty? just sayin..."
        ]
        @start_phrase = "The code has been set."
    end

    def play
        puts "Would you like to 'SET' the code or 'GUESS' the code?"
        game_type = gets.chomp.upcase
        if game_type == "GUESS"
            human_play
        elsif game_type == "SET"
            cpu_play
        else
            puts "yeah, ok... SET or GUESS?"
            sleep 1
            self.play
        end
    end

    #private

    ######################################################################
    ##### HUMAN PLAY - CPU SETS CODE, HUMAN GUESSES, CPU GIVES CLUES #####
    ######################################################################

    def human_play
        cpu_generate_code
        puts @start_phrase
        sleep 0.5
        while game_over? == false
            sleep 1.5
            user_pick_colors
            check_clue_clear
            self.turn_count += 1
        end

        puts @winning_statement.shuffle.first
        puts "the code was:"
        show_code
        binding.pry
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

    def user_pick_colors
        instruct = "please choose one of five options: red, blue, green, yellow, or pink"
        puts instruct
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

    #########################################################################
    ##### CPU PLAY - USER SETS CODE, COMPUTER GUESSES, USER GIVES CLUES #####
    #########################################################################
    def cpu_play
        human_set_code
        @submitted_guess = []
        puts @start_phrase
        sleep 1
        cpu_pick_colors


    end

    def human_set_code
        instruct = "please choose one of five options: red, blue, green, yellow, or pink"
        puts instruct
        i = 1
        while i <= 5
            puts "choose color # #{i}:"
            color = gets.chomp.to_s.downcase
            clear_line(2)

            case color
            when "red"
                @code.push(@red)
            when "blue"
                @code.push(@blue)
            when "green"
                @code.push(@green)
            when "yellow"
                @code.push(@yellow)
            when "pink"
                @code.push(@pink)
            else
                puts instruct
                redo
            end
            i += 1
        end

    end

    def cpu_pick_colors
        if @turn_count == 1 || @clue.all?(@gap)
            generate_five_random
        end
            # Look at the clue and only fill the indexes that are not green those that are 
            # green use the same color in that index
            # if blue clue use those colors first, but put them in different indexes
            # if a color is matched with @gap in the clue, don't use that color anymore, unless
            # there is a green clue for said color.
        

    end

    def human_check_code
        instruct = ["Please place put 'GREEN' if the color is correct and in the correct spot.",
        "'BLUE' if the color is in the code, but not in its current position",
        "'WRONG' if the color is not in the code"]
        puts instruct
        i = 1
        while i <= 5
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
    
    def enter_guess
        @guess_list << @submitted_guess
        guess = "#{self.turn_count}. #{@submitted_guess.join("#{@gap} ")}"
        display_turn(guess)
    end

    def enter_clue
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

    def check_clue_clear
        cpu_check_code
        enter_clue
        clear
    end

    def show_code
       puts @code.join("#{@gap} ")
    end
    
    def clear_line(number_of_lines)
        print "\e[A\e[2K" * number_of_lines
    end

    def generate_five_random
        five_colors = []
        5.times do
            five_colors.push(@choices[rand(5)])
        end
        five_colors
    end

    def display_turn(guess)
        @display_list[self.turn_count - 1] = guess
        puts puts @display_list.last
    end

end

game = Mastermind.new
game.play



# print "\e[A\e[2K"
require 'pry'

class String
    def colorize(color_code)
        "\e[#{color_code}m#{self}\e[0m"
    end

    def red
        colorize(31)
    end

    def blue
        colorize(34)
    end

    def green
        colorize(32)
    end

    def yellow
        colorize(33)
    end

    def pink
        colorize(35)
    end

    def bg_blue
        colorize(44)
    end

    def bg_green
        colorize(42)
    end

    def bold
        "\e[1m#{self}\e[22m"
    end
end

class Mastermind < String
    attr_accessor :turn_count

    def initialize
        @red = "*".red.bold
        @blue = "*".blue.bold
        @green = "*".green.bold
        @yellow = "*".yellow.bold
        @pink = "*".pink.bold
        @color_but_space = "  ".bg_blue
        @color_and_space = "  ".bg_green

        @code = []
        @guess_list = []
        @submitted_guess = []
        @clue = ['  ', '  ', '  ', '  ', '  ']
        @choices = [@red, @blue, @green, @yellow, @pink]
        @turn_count = 1
        @winning_statement = [
            "Congrats, you did it! You're pretty smart.",
            "Wow, how did you do that so fast? It only took you #{self.turn_count} tries!}",
            "OK, ok, why don't you give someone else a turn hotshot...",
            "You're not as dumb as you look.",
            "Maybe try a harder difficulty? just sayin..."
        ]
    end

    def play
        puts "Would you like to 'SET' the code or 'GUESS' the code?"
        game_type = gets.chomp.upcase
        if game_type == "GUESS"
            cpu_generate_code
            puts "The code has been set."
            sleep 0.5
            while game_over? == false
                sleep 1.5
                pick_colors
                check_enter_clear
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
                puts("Goodbye!")
            end
        elsif game_type == "SET"
            puts "functionality coming soon... :)"
            sleep 1
            self.play
        else
            puts "yeah, ok... SET or GUESS?"
            sleep 1
            self.play
        end
    end

    private

    def cpu_generate_code
        5.times do
            @code.push(@choices[rand(5)])
        end
       @code.join('   ')
    end

    def pick_colors
        puts "please choose from these five options: red, blue, green, yellow, or pink"
        i = 1
        while i <= 5
            puts "choose color # #{i}:"
            color = gets.chomp.to_s.downcase
            print "\e[A\e[2K" * 2

            case color
            when "red"
                @submitted_guess.push(@red)
            when "blue"
                @submitted_guess.push(@blue)
            when "green"
                @submitted_guess.push(@green)
            when "yellow"
                @submitted_guess.push(@yellow)
            when "pink"
                @submitted_guess.push(@pink)
            else
                puts "please choose one of five options: red, blue, green, yellow, or pink"
                redo
            end
            i += 1
        end
    end

    def check_code
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
            if @clue[index] == "  " && code_color_count.keys.include?(my_color)
                @clue[index] = @color_but_space
                code_color_count[my_color] -= 1
                code_color_count.select! { |key, value| value > 0 }
            end
        end
    end

    def enter_guess
        guess = "#{self.turn_count}. #{@submitted_guess.join('   ')}     | #{@clue.join(' | ')} |"
        @guess_list << guess
        @guess_list.each do |row|
           puts puts row
        end
    end

    def game_over?
        @submitted_guess == @code ? true : false
    end

    def clear
        if game_over? == false
            @submitted_guess = []
            @clue = ["  ", "  ", "  ", "  ", "  "]
        end
    end

    def check_enter_clear
        check_code
        enter_guess
        clear
    end

    def show_code
       puts @code.join('   ')
    end
end

game = Mastermind.new
game.play



# print "\e[A\e[2K"
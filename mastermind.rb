require 'pry'

class String
    def colorize(color_code)
        "\e[#{color_code}m#{self}\e[0m"
    end

    def bold
        "\e[1m#{self}\e[22m"
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



end

class Mastermind < String
    attr_reader :submitted_guess

    def initialize
        @red = "*".red.bold
        @blue = "*".blue.bold
        @green = "*".green.bold
        @yellow = "*".yellow.bold
        @pink = "*".pink.bold
        @color_but_space = "  ".bg_blue
        @color_and_space = "  ".bg_green

        @code = []
        @all_guesses = []
        @submitted_guess = []
        @all_clues = []
        @clue = [' ', ' ', ' ', ' ', ' ']
        @choices = [@red, @blue, @green, @yellow, @pink]
    end

    def play

    end

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

        @submitted_guess.each_with_index do |my_color, index|
            if my_color == @code[index]
                @clue[index] = @color_and_space
                code_color_count[my_color] -= 1
                code_color_count.select! { |key, value| value > 0 }
            end
        end

        @submitted_guess.each_with_index do |my_color, index|
            if @clue[index] == " " && code_color_count.keys.include?(my_color)
                @clue[index] = @color_but_space
                code_color_count[my_color] -= 1
                code_color_count.select! { |key, value| value > 0 }
            end
        end
    end

    def enter_guess
        @submitted_guess = "#{@submitted_guess.join('   ')}     | #{@clue.join(' | ')} |"
        @all_guesses << @submitted_guess
        @all_guesses.each do |row|
           puts puts row
        end
    end

    def clear
        @submitted_guess = []
        @clue = [" ", " ", " ", " ", " "]
    end

    def check_enter_clear
        check_code
        enter_guess
        clear
    end

    def show_code
       puts @code.join('   ')
    end

    def show_board
    end


    # def show_choices
    #    @choices.join('   ')
    # end

end





# print "\e[A\e[2K"
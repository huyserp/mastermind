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
end

class Mastermind < String

    def initialize
        @red = "*".red
        @blue = "*".blue
        @green = "*".green
        @yellow = "*".yellow
        @pink = "*".pink

        @all_guesses = []
        @submitted_guess = []
        @choices = [@red, @blue, @green, @yellow, @pink]
        @code = []
    end

    def cpu_generate_code
        @code = []
        5.times do
            @code.push(@choices[rand(4)])
        end
       @code.join('   ')
    end

    def make_guess
        i = 1
        while i <= 5
            puts "choose color # #{i}:"
            color = gets.chomp.to_s.downcase

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

        puts @submitted_guess.join('   ')
    end

    def enter_guess
        @all_guesses.push(@submitted_guess)
        @submitted_guess = []
        @all_guesses.each do |row|
           puts row.each { |colors| colors }.join('   ')
        end
    end

    def show_code
        @code.join('   ')
    end

    def show_choices
       @choices.join('   ')
    end

end






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

    def show_code
        @code.join('   ')
    end

    def show_choices
       @choices.join('   ')
    end

end






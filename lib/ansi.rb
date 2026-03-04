# Provide tools for printing colorized text.
class ANSI
  COLORS = {
    reset: "\e[0m",
    black: "\e[0;30m",
    bright_black: "\e[1;30m",
    red: "\e[0;31m",
    bright_red: "\e[1;31m",
    green: "\e[0;32m",
    bright_green: "\e[1;32m",
    yellow: "\e[0;33m",
    bright_yellow: "\e[1;33m",
    blue: "\e[0;34m",
    bright_blue: "\e[1;34m",
    magenta: "\e[0;35m",
    bright_magenta: "\e[1;35m",
    cyan: "\e[0;36m",
    bright_cyan: "\e[1;36m",
    white: "\e[0;37m",
    bright_white: "\e[1;37m"
  }

  class << self
    # Colorizes the string with the given color name and ensures a
    # color reset is included.
    def colorize(str, color:)
      "#{COLORS[color]}#{str}#{COLORS[:reset]}"
    end

    # Returns the named color code for initiating manual color changes
    # in terminal text.
    def color(name)
      COLORS[name]
    end

    # Reset the ANSI color code.
    def reset
      color(:reset)
    end

    # Dynamically defines color helpers like red, bright_red, etc. as
    # defined in the ANSI constant.
    COLORS.each do |(color)|
      next if color == :reset
      define_method "#{color}" do |str|
        colorize(str, color: color)
      end
    end
  end
end


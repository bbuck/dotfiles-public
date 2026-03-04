class Logger
  LOG_METHODS = {
    created: :bright_green,
    done: :bright_white,
    error: :bright_red,
    failed: :bright_red,
    identical: :bright_yellow,
    removed: :bright_red,
    skipped: :bright_white,
    unlinked: :bright_red,
    wrote: :bright_green,
    copied: :bright_green,
    linked: :bright_green,

    success: :bright_green,
    creating: :bright_red,
    unlinking: :bright_red,
    removing: :bright_red,
    installing: :bright_green,
    installed: :bright_yellow,
    skipping: :bright_white,
  }

  class << self
    def status(status, color, message)
      colorized_status = "#{status.to_s.downcase.rjust(column_width)}:"
      puts "#{ANSI.colorize(colorized_status, color: color)} #{message}"
    end

    LOG_METHODS.each do |(status, color)|
      define_method(status) { |msg| status(status, color, msg) }
    end

    def column_width
      return @column_width if @column_width

      max_width = LOG_METHODS
        .keys
        .map(&:to_s)
        .map(&:length)
        .max
      @column_width = max_width + 1
    end
  end
end


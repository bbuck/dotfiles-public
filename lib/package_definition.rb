require "psych"

class PackageDefinition
  class << self
   def from(data)
      case data
      when String then self.new(short: data, full: data, executable: data)
      when Hash then self.new(
        short: data['short'] || data['full'],
        full: data['full'] ||  data['short'],
        executable: data['executable'],
      )
      else
        raise ArgumentError, "Cannot construct Package Definition from #{data.inspect}"
      end
    end
  end

  attr_reader :short, :full, :executable

  def inspect
    "<#{self.class.name} short=#{short} full=#{full}>"
  end

  def to_s
    representation = "Package #{full}"
    return representation if short == full
    representation + " (#{short})"
  end

  private

  def initialize(short:, full:, executable: nil)
    @short = short
    @full = full
    @executable = executable
  end
end

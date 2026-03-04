# Wraps dotfile configuration definitions.
class CustomDotfile
  class << self
    def from(hash)
      new(
        local_path: hash["local"],
        action: hash["action"],
        mac_os: hash["mac_os"],
        linux: hash["linux"],
        unix: hash["unix"],
        windows: hash["windows"]
      )
    end
  end

  attr_reader :local_path, :action, :mac_os, :linux, :unix, :windows

  def skip?
    action == "skip"
  end

  def to_dotfile
    Dotfile.new(local_path)
  end

  def destination()
    case current_os
    when :mac_os then mac_os
    when :unix then unix
    when :linux then linux
    when :windows then windows
    else
      raise ArgumentError, "OS #{os} not supported"
    end
  end

  private

  def initialize(local_path:, action:, mac_os:, unix:, linux:, windows:)
    @local_path = local_path
    @action = action
    @mac_os = mac_os
    @linux = linux
    @unix = unix
    @windows = windows
  end
end

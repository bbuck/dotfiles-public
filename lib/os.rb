require "open3"

# Wraps details specific to an OS about where information is typically stored
class OSDetails
  extend Buildable

  class << self
    def execute(cmd)
      _, _, status = Open3.capture3(cmd)
      status
    end
  end

  attr_reader :name, :git_credential_helper, :ssh_path, :ignorecase,
    :installer, :install_checker, :tasks, :config_path

  private def initialize(builder)
    @name = builder.get_name || 'unknown'
    @git_credential_helper = builder.get_git_credential_helper || ''
    @ssh_path = builder.get_ssh_path || nil
    @ignorecase = builder.get_ignorecase || false
    @install_checker = builder.get_install_checker || Proc.new { false }
    @installer = builder.get_installer || Proc.new { false }
    @tasks = builder.get_tasks || []
    @config_path = builder.get_config_path || nil
  end

  class Builder < BaseBuilder
    builds_attributes %i[name git_credential_helper ssh_path ignorecase
      install_checker installer config_path]
    builds_multivalue_attributes %i[tasks]
  end

  def installed?(program)
    @install_checker.call(program)
  end

  def install(program)
    @installer.call(program)
  end

  def ignorecase?
    !!ignorecase
  end
end

# Definition of values per operating system.
OS = {
  mac_os: OSDetails.build do
    name :mac_os
    git_credential_helper "osxkeychain"
    ssh_path Config.home.join(".ssh")
    config_path Config.home.join(".config")
    ignorecase true,
    install_checker { |p| OSDetails.execute("which #{p}").to_i.zero? }
    installer { |p| OSDetails.execute("brew install #{p}").to_i.zero? }
    tasks 'homebrew:install'
  end,
  linux: OSDetails.build do
    name :linux
    git_credential_helper "cache"
    ssh_path Config.home.join(".ssh")
    install_checker { |p| OSDetails.execute("which #{p}").to_i.zero? }
    config_path Config.home.join(".config")
  end,
  windows: OSDetails.build do
    name :windows
    git_credential_helper "wincred"
    ignorecase true
  end,
  unix: OSDetails.build {
    name :unix
    ssh_path Config.home.join(".ssh")
    install_checker { |p| OSDetails.execute("which #{p}").to_i.zero? }
  },
  unknown: OSDetails.build {},
}

# Determines the current OS based on the ruby configuration.
def current_os
  @os ||= (
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac ?os/
      :mac_os
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      :unknown
    end
  )
end

# Fetches the details for the current operating system.
def os_details
  OS[current_os]
end

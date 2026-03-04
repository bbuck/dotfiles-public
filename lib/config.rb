require "pathname"
require "fileutils"
require "psych"

class Config
  class << self
    def home
      @home ||= Pathname.new(ENV["HOME"])
    end

    def pwd
      @pwd ||= Pathname.new(FileUtils.pwd)
    end

    # TODO: move this out of Config and into OSDetails
    def xdg_config_home
      @xdg_config_home ||= Pathname.new(ENV['XDG_CONFIG_HOME'] || '')
    end

    # TODO: move this out of Config and into OSDetails
    def omz_plugin_path
      return @omz_plugin_path if @omz_plugin_path
      path_string = ENV['ZSH_CUSTOM'] || home.join('.oh-my-zsh', 'custom', 'plugins')
    end

    def packages
      @packages ||= dotfile_config.fetch("packages", []).map { |p| PackageDefinition.from(p) }
    end

    def custom_dotfiles
      @custom_dotfiles ||= dotfile_config.fetch("dotfiles", []).map { |d| CustomDotfile.from(d) }
    end

    private

    def dotfile_config
      @config ||= Psych.load_file(pwd.join('dotfiles_config.yml'))
    end
  end
end


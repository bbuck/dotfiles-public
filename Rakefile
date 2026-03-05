require "rake"
require "erb"
require "rbconfig"
require "yaml"
require "fileutils"

require_relative "./lib/load"

desc "Prepare the dotfiles project for use"
task :init do
  hook_dir = Config.pwd.join("meta", "hooks", "*")
  Dir[hook_dir].each do |file|
    new_path = Config.pwd.join(".git", "hooks", Pathname.new(file).basename)
    copy_dotfile(file, new_path)
  end
end

desc "install the dotfiles into user's home directory"
task :install do
  dotfiles_path = Config.pwd.join('files')
  dotfiles = Dir[dotfiles_path.join('{*,.*}.{erb,copy,symlink}')].map { |df| Dotfile.new(dotfiles_path.join(df)) }
  destination = Config.home
  dotfiles.each do |df|
    dotfile_out_path = destination.join(df.destination_name)

    if df.identical?(with: dotfile_out_path)
      Logger.identical(dotfile_out_path)
      next
    end

    if df.copy? && Dotfile.exists?(dotfile_out_path)
      print ANSI.bright_white("overwrite ")
      print ANSI.bright_yellow("~/#{dotfile_out_path.relative_path_from(Config.home)}")
      print ANSI.bright_white(" [ynq] >> ")

      case $stdin.gets.chomp.strip
      when 'q', 'quit'
        exit
      when 'y', 'yes'
        Dotfile.remove(dotfile_out_path)
        Logger.removed(dotfile_out_path)
      else
        next
      end
    end

    result = df.execute(destination)
    Logger.status(result, :bright_green, dotfile_out_path)
  end

  Rake::Task["install_config_folders"].execute
  Rake::Task["install_special_dotfiles"].execute
end

desc "Install special dotfiles in the configuration file."
task :install_special_dotfiles do
  Config.custom_dotfiles.each do |custom_dotfile|
    if custom_dotfile.skip?
      Logger.skipped(custom_dotfile.local_path)
      next
    end

    dotfile = custom_dotfile.to_dotfile
    destination = custom_dotfile.destination
    next unless destination
    destination = destination
        .sub('$HOME', Config.home.to_s)
        .sub('$XDG_CONFIG_HOME', Config.xdg_config_home.to_s)

    if Dotfile.exists?(destination)
      if dotfile.identical?(with: destination)
        Logger.identical(destination)
      else
        Logger.exists(destination)
      end
    else
      case custom_dotfile.action
      when 'link'
        dotfile.symlink(as: destination)
        Logger.linked(destination)
      when 'copy'
        dotfile.copy(to: destination)
        Logger.copied(destination)
      when 'render'
        dotfile.write(to: destination)
        Logger.wrote(destination)
      else
        raise ArgumentError, "The action '#{dotfile_config['action']}' is not implemented"
      end
    end
  end
end

desc "Installs .config folders if the current OS supports them."
task :install_config_folders do
  if os_details.config_path
    config_folders = Dir[Config.pwd.join("*.config")].map { |p| Dotfile.new(Config.pwd.join(p)) }
    FileUtils.mkdir_p(os_details.config_path)
    config_folders.each do |config_folder|
      folder_name = config_folder.destination_name.sub(".config", "")
      destination = os_details.config_path.join(folder_name)
      if Dotfile.exists?(destination)
        if config_folder.identical?(with: destination)
          Logger.identical(destination)
        else
          Logger.skipped("#{destination} exists")
        end
      else
        config_folder.symlink(as: destination)
        Logger.linked(destination)
      end
    end
  else
    Logger.skipped("config files: no config path defined for #{current_os}")
  end
end

desc "Install known and desired packages."
task :install_packages do
  Config.packages.each do |package|
    if package.executable && os_details.installed?(package.executable)
      Logger.installed(package.full)
      next
    end
    Logger.installing(package.full)
    os_details.install(package.full)
  end
end

desc "remove all dotfiles (from this repo) from your home directory"
task :uninstall do
  dotfiles_path = Config.pwd.join('files')
  dotfiles = Dir[dotfiles_path.join('{*,.*}.{erb,copy,symlink}')].map { |df| Dotfile.new(dotfiles_path.join(df)) }
  destination = Config.home
  dotfiles.each do |df|
    dotfile_out_path = destination.join(df.destination_name)
    Dotfile.remove(dotfile_out_path)
    Logger.removed(dotfile_out_path)
  end
end

desc 'Perform basic setup and installations based on the operating system'
task :init_machine do
  os_details.tasks.each do |task|
    Rake::Task[task].execute
  end
  Rake::Task["install_packages"].execute
end

desc 'ZSH specific installation tasks'
namespace :zsh do
  task :install do
    if os_details.installed?('zsh')
      Logger.installed("zsh")
    else
      Logger.installing('zsh')
      os_details.install('zsh')
      Logger.installed('zsh')
    end

    if os_details.installed?('omz')
      Logger.installed("oh-my-zsh")
    else
      Logger.installing("oh-my-zsh")
      `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
      Logger.installed('oh-my-zsh')
    end

    Rake::Task["zsh:install_custom_plugins"].execute
    Rake::Task["zsh:install_autosuggestions"].execute
    Rake::Task["zsh:install_syntax_highlighting"].execute
  end

  task :install_custom_plugins do
    current_path = Config.pwd.join("personal")
    new_path = Config.omz_plugin_path
    if !File.exist?(new_path)
      FileUtils.mkdir_p(new_path)
      Logger.created("$ZSH_CUSTOM/plugins/personal")
    end
    Dotfile.new(current_path).symlink(as: new_path)
    Logger.linked("$ZSH_CUSTOM/plugins/personal")
  end

  task :install_autosuggestions do
    Logger.installing("zsh-autosuggestions")
    os_details.install("zsh-autosuggestions")
  end

  task :install_syntax_highlighting do
    Logger.installing("zsh-syntax-highlighting")
    os_details.install("zsh-syntax-highlighting")
  end
end

desc 'Homebrew related management tasks'
namespace :homebrew do
  desc 'Install homebrew using an installation snippet found on https://brew.sh'
  task :install do
    if current_os != :mac_os
      Logger.skipping("not on macOS")
      next
    end

    if os_details.installed?('brew')
      Logger.installed('Homebrew appears to be installed')
      next
    else
      Logger.installing('Installing homebrew')
    end

    status = OSDetails.execute('/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"')
    if status == 0
      Logger.success('Homebrew has been installed')
    else
      Logger.failed('Homebrew failed to install: failed with code #{status}')
    end
  end
end


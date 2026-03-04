# Dotfiles

This repository provides a framework for storing and sharing your dotfiles
across multiple computer systems, and naturally provides a way for dotfile
changes to be synced regularly (through git).

## History

This repository started as a fork (and was heavily inspired) by
[Ryan Bates dotfiles](https://github.com/ryanb/dotfiles) (forked circa 2012).

## Installation

### Before Installing Locally

Clone/fork this repository and make it private (ideally) or move it to your
git host of choice. This ensures that all of your changes are truly yours.

The tooling itself is written in Ruby, Ruby > 1.9 is required to be installed
on the machine before you can run the Rake commands.

### 1. Clone the Repository

Clone your fork/copy of the repository somewhere on your machine, I typically
store them in `~/.dotfiles` (example commands assume this where your repo is
cloned).

```shell
git clone git@github.com:username/dotfiles ~/.dotfiles
cd ~/.dotfiles
```

### 2. Copy In Your Configuration

Copy the dotfiles you want to share across systems into the `files` directory.
You'll need to rename them based on how you want the dotfiles tooling to
install them. For example:

```shell
mv ~/.zshrc ~/.dotfiles/files/.zshrc.symlink
mv ~/.gitignore ~/.dotfiles/files/.gitignore.copy
mv ~/.gitconfig ~/.dotfiles/files/.gitconfig.copy.erb
```

#### .symlink

Dotfiles that end with `.symlink` will be linked into your home directory, this
allows you to avoid thinking about your dotfiles repo anytime you need to
make a change. Simply `nvim ~/.zshrc` (or whichever editor you use) and make
your changes. Just remember to regularly jump back into `~/.dotfiles` and commit
so changes can propagate.

Symlinking the dotfiles also has the advantage that pulling new changes locally
will automatically be seen next time you run a tool that uses dotfile configuration
without any additional effort.

#### .copy

The extension `.copy` is straightforward, it makes a hard copy of the file
locally. This is useful if the file itself may typically gather or contain
very specific information for a single computer. Unlike `.symlink`, changes
to copied files will not be reflected in the `~/.dotfiles` folder and would
have to be manually copied back in and installed on other computers.

The typical use case for me here is with `~/.gitconfig` I store my work or
personal github username, singing key identifiers, and more that are typically
computer specific. The base config is the same, but over time I add specific
changes that shouldn't be shared.

#### .copy.erb

In very specific cases you may want to control exactly what gets output in a
copied file. The special `.copy.erb` extension will run the file through Ruby's
ERB pipeline allowing you to inject any data you wish into the file before
the final generated output is then copied into place.

The typical use case here for me is `~/.gitconfig`. I have the ERB template
ask me for my github username and email when the file is installed so I can
customize during the dotfile installation process instead of having to go in
and change it after it's copied. Additionally it uses OS specific definitions
to populate a credential store specific to the OS it's being installed on.

#### ~/.config/* folders

Not all tools ues a flat dotfile anymore. In many cases you'll find configuration
folders in `~/.config/*` (or similar) that contain one ore more configuration
files. These config folders are supported as well. Simply move the entire folder
into the root of the repository as `.config`. For example, for `~/.config/kitty`
you would run `mv ~/.config/kitty kitty.config`. These folders then get symlinked
into the most appropriate `~/.config` or similar location based on your OS
and configuration.

### 3. (Optional) Initialize your Machine

The dotfiles feature a `rake zsh:install` task that will install ZSH, oh-my-zsh,
and then setup the `~/.dotfiles/personal` folder as a plugin in the oh-my-zsh
plugin path for you. Using this method for custom configuration over modifying
`~/.zshrc` is more reselient to oh-my-zsh changes, and easy to use without
oh-my-zsh. It provides a special "home" container for your custom shell configuration
independent of `~/.zshrc` (or other profile). If you choose to leverage it.

To setup your machine for dotfiles usage (required if you want to use `packages`)
you can run `rake init_machine`. Some platforms, like macOS, don't necessarily
come with a local package manager. In these cases OS configurations (found in
`lib/os.rb`) can specify rake tasks to execute for specific systems. For
example the macOS configuration will install homebrew. Which it requires to
install shared packages.

### 4. Install

Once you've copied in all your dotfiles, the next step is to run `install`.

```shell
rake install
```

This pulls all the files inside your `~/.dotfiles/files` directory and will
symlink or copy them into your home directory. Then it will symlink your
`~/.dotfiles/*.config` folders into the config home (usually `~/.config`). And
finally it will go through any custom dotfile configurations you have defined
in your `~/.dotfiles/dotfiles_config.yml`.

#### Install packages

If you have a common set of external/third party tools you use regularly you
can define them under `packages:` in `dotfiles_config.yml` and then install
them via:

```shell
rake install_packages
```

This will use OS specific configuration to install the packages through the
appropraite package manager for you current system.

### 5. Uninstall

If you're ready to remove your configuration from a machine you can simply run
`rake uninstall` to remove all the local dotfiles that were symlinked or copied
into your home directory.

**NOTE:** This does not currently remove `~/.config` symlinks.

## Modification

The core lib powering the toolset is stored in `lib/` and written in Ruby. The
primary powerhouse is the `Dotfile` (`lib/dotfile.rb`) class that manages what to do, and executes
actions, on specific files. You can extend capabilities for specific dotfiles
here.

OS configurations are basic, and were written to my needs and setups so they
will likely need to be modified for non-standard installations or custom tooling.
You can define OS configurations in `lib/os.rb`. You can customize and control
OS resolution by modifying the `current_os` function in that file, which should
map to a configuration on the `OS` constant in the same file. This allows the
function `os_details` to pull the correct OS config base which is used for a
variety of things like config directories, credential tools, package installation,
etc.

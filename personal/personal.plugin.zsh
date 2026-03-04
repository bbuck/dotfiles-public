# Custom env variables/functions/etc

# used to store paths for testing/assignment to avoid invoking a command
# multiple times
local temp_path=""

# ############################################################################
#
# Exports
#
# ############################################################################

# export ZSH_THEME=powerlevel10k/powerlevel10k
# export Projects=~/Dev
# export EDITOR=nvim
# export BUNDLER_EDITOR=nvim
# export GPG_TTY=$(tty)

# ############################################################################
#
# Functions
#
# ############################################################################

# Makes a new directory (with mkdir -p) and then `cd` into it.
mkcd() {
  mkdir -p $@ && cd $@
}

# Execute a .env file (key=value pairs) and have them exported into the current
# environment.
# Usage: dotenv <path-to-env-file>
dotenv() {
  set -a
  source $1
  set +a
}

# node_scripts() {
# 	cat package.json | jq '.scripts'
# }

## Uncomment below if you want to split your personal config up across multiple
## shell files, for example I have a game_dev.sh for game development specific
## configurations and work.sh for work configuration. This also make it easy
## to source your changes without reloading zshrc which oh-my-zsh isn't always
## a fan of.
##
# _plugin_script_file=${(%):-%x}
# _plugin_script_dir=${_plugin_script_file:A:h}
#
# re_source() {
# 	local sourceables=(game_dev work)
# 	for sourceable in $sourceables; do
# 		if [[ -f $_plugin_script_dir/$sourceable.zsh ]]; then
# 			source $_plugin_script_dir/$sourceable.zsh
# 		fi
# 	done
# }
#
# re_source

# ############################################################################
#
# Plugin Customization / Activation
#
# ############################################################################

## ARM macOS paths
# if [ -f "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
#   source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#   zstyle ':bracketed-paste-magic' active-widgets '.self-*'
# fi
#
# if [ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
#   source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# fi
#
## regular paths
# if [ -f "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
#   source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#   zstyle ':bracketed-paste-magic' active-widgets '.self-*'
# fi
#
# if [ -f "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
#   source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# fi

# ############################################################################
#
# Aliases
#
# ############################################################################

# which -s lsd &> /dev/null && alias ls="lsd"
#
# export BAT_THEME=Nord
# which -s bat &> /dev/null && alias cat="bat"

# ############################################################################
#
# Keybindings
#
# ############################################################################

# bindkey \^K kill-line

# ############################################################################
#
# Setup Execution
#
# ############################################################################

# which starship &> /dev/null
# if [[ $? -eq 0 ]]; then
# 	eval "$(starship init zsh)"
# fi

# which oh-my-posh &> /dev/null
# if [[ $? -eq 0 && "$TERM_PROGRAM" != "Apple_Terminal" ]]; then
# 	eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/omp.json)"
# fi

# which atuin &> /dev/null
# if [[ $? -eq 0 ]]; then
# 	eval "$(atuin init zsh)"
# fi

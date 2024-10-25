# Source Aliases
source $ZDOTDIR/aliases

# Path Settings
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:$(npm root -g)/.bin
export PATH="/usr/lib/google-cloud-sdk/bin:$PATH"
export EDITOR="nvim"

# XDG Base Directory and XDG Ninja Recommendations
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_STATE_HOME=$HOME/.local/state
export XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR

# Application-specific XDG configurations
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
export KERAS_HOME="$XDG_STATE_HOME/keras"
export NIMBLE_DIR="$XDG_DATA_HOME/nimble"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export ANDROID_HOME="$XDG_DATA_HOME/android"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"
export SPOTDL_CONFIG="$XDG_CONFIG_HOME/spotdl.yml"

# npm configurations
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export NPM_CONFIG_PREFIX="$XDG_DATA_HOME"/npm
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME"/npm
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR"/npm

# Ren'Py configuration
export RENPY_PATH_TO_SAVES="$XDG_DATA_HOME"

# Desktop and Display Settings
export MOZ_ENABLE_WAYLAND=1

# Miscellaneous Settings
export LIBSEAT_BACKEND=logind
export BROWSER=floorp

# User-provided Original Variables and Settings
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export TEXMFVAR="$XDG_CACHE_HOME"/texlive/texmf-var
export SSB_HOME="$XDG_DATA_HOME"/zoom
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel
export GOPATH="$XDG_DATA_HOME/go"
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export DVDCSS_CACHE="$XDG_DATA_HOME"/dvdcss
export WINEPREFIX="$XDG_DATA_HOME"/wine
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java

# History Settings
export HISTFILE="$XDG_STATE_HOME"/zsh/history

# Hostname Specific Directories
if [ "$(hostname)" = "7ktx-desktop" ]; then
    export XDG_MUSIC_DIR="/data/Music"
    export WALLPAPER_DIR="$HOME/DCIM/Wallpapers/32_9"
elif [ "$(hostname)" = "7ktx-laptop" ]; then
    export XDG_MUSIC_DIR="$HOME/Music"
    export WALLPAPER_DIR="$HOME/DCIM/Wallpapers/16_9"
fi
export WALLPAPER_VIDEO_DIR="$HOME/DCIM/Wallpapers_Video"

export_vars_from_files() {
    local dir_path=$1
    for file_path in "$dir_path"/*.txt; do
        if [[ -f $file_path ]]; then
            var_name=$(basename "$file_path" .txt)  # Extract the file name without extension
            export $var_name=$(cat "$file_path")    # Export the variable
        fi
    done
}

# Export all variables from the $HOME/Tokens directory
export_vars_from_files "$HOME/Tokens"

# Aliases for XDG compliance
alias wget="wget --hsts-file="$XDG_DATA_HOME"/wget-hsts"
alias svn="svn --config-dir $XDG_CONFIG_HOME/subversion"
alias yarn="yarn --use-yarnrc $XDG_CONFIG_HOME/yarn/config"
alias mocp="mocp -M "$XDG_CONFIG_HOME"/moc"
alias mocp="mocp -O MOCDir="$XDG_CONFIG_HOME"/moc"

# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# =============================================================================
#  BASE CONFIGURATION
# =============================================================================
# XDG Base Directories
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_STATE_HOME=$HOME/.local/state
export XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR

# Core Path and Editor Settings
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:$(npm root -g)/.bin
export PATH="/usr/lib/google-cloud-sdk/bin:$PATH"
export EDITOR="nvim"

# =============================================================================
#  DEVELOPMENT TOOLS
# =============================================================================
# Python Related
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"

# Node.js and NPM
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_PREFIX="$XDG_DATA_HOME/npm"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR/npm"
export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME/npm/config/npm-init.js"

# Android Development
export ANDROID_HOME="$XDG_DATA_HOME/android"
export ANDROID_USER_HOME="$XDG_DATA_HOME/android"

# Other Development Tools
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
export KERAS_HOME="$XDG_STATE_HOME/keras"
export NIMBLE_DIR="$XDG_DATA_HOME/nimble"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GOPATH="$XDG_DATA_HOME/go"
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME/java"

# =============================================================================
#  SYSTEM AND DESKTOP
# =============================================================================
# Desktop Settings
export MOZ_ENABLE_WAYLAND=1
export LIBSEAT_BACKEND=logind
export BROWSER=floorp
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"

# System Configurations
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"

# =============================================================================
#  APPLICATIONS
# =============================================================================
# Media and Entertainment
export SPOTDL_CONFIG="$XDG_CONFIG_HOME/spotdl.yml"
export DVDCSS_CACHE="$XDG_DATA_HOME/dvdcss"
export WINEPREFIX="$XDG_DATA_HOME/wine"
export TEXMFVAR="$XDG_CACHE_HOME/texlive/texmf-var"
export SSB_HOME="$XDG_DATA_HOME/zoom"

# =============================================================================
#  MACHINE-SPECIFIC SETTINGS
# =============================================================================
# Hostname-specific directories
if [ "$(hostname)" = "y0usaf-desktop" ]; then
    export XDG_MUSIC_DIR="/data/Music"
    export WALLPAPER_DIR="$HOME/DCIM/Wallpapers/32_9"
elif [ "$(hostname)" = "y0usaf-laptop" ]; then
    export XDG_MUSIC_DIR="$HOME/Music"
    export WALLPAPER_DIR="$HOME/DCIM/Wallpapers/16_9"
fi
export WALLPAPER_VIDEO_DIR="$HOME/DCIM/Wallpapers_Video"

# =============================================================================
#  FUNCTIONS AND ALIASES
# =============================================================================
# Token management function
export_vars_from_files() {
    local dir_path=$1
    for file_path in "$dir_path"/*.txt; do
        if [[ -f $file_path ]]; then
            var_name=$(basename "$file_path" .txt)
            export $var_name=$(cat "$file_path")
        fi
    done
}

# Export tokens
export_vars_from_files "$HOME/Tokens"

# Source aliases file
source $ZDOTDIR/aliases

# XDG compliance aliases
alias adb='HOME="$XDG_DATA_HOME/android" adb'
alias wget="wget --hsts-file="$XDG_DATA_HOME"/wget-hsts"
alias svn="svn --config-dir $XDG_CONFIG_HOME/subversion"
alias yarn="yarn --use-yarnrc $XDG_CONFIG_HOME/yarn/config"
alias mocp="mocp -M "$XDG_CONFIG_HOME"/moc"
alias mocp="mocp -O MOCDir="$XDG_CONFIG_HOME"/moc"

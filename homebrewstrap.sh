#! /usr/bin/env bash

# Human Readable and Machine Executable Instructions
# on how to homebrew strap your macbook and install programming environments

########### HELPER FUNCTIONS

_boot() {
  printf "\n$(tput bold)>>> HOMEBREW STRAP:: %b $(tput sgr0)" "$1\n"
}

_act() {
    printf "\n$(tput bold)$(tput setaf 4)>>> ACTION:: %b $(tput sgr0)" "$1\n"
}

_info() {
    printf "\n$(tput bold)$(tput setaf 3)### INFO:: %b $(tput sgr0)" "$1\n"
}

_warn() {
    printf "\n$(tput bold)$(tput setaf 1)### WARNING:: %b $(tput sgr0)" "$1\n"
}

_skip() {
    printf "\n$(tput bold)^^^ SKIPPING:: %b $(tput sgr0)" "$1\n"
}

_confirm_or_exit() {
    if _confirm_yes "$1"; then
        echo "==> MOVING ON:"
    else
        _warn "ABORT and EXIT. Take steps necessary to answer yes and rerun this script";
        exit -1;
    fi
}

_confirm_yes(){
    read -r -p "$(tput bold)$(tput setaf 6) !!! QUESTION: $1 [Y/n] $(tput sgr0)" response
    if [[ $response =~ ^(n) ]]; then
        return 1; #no
    else
        return 0; #yes default
    fi
}


_boot "START INTERACTIVE SCRIPT."

_warn "This script PROMPTS YOU for input. Some tool installations require your password."

_act "CHECKING your username permissions: you $(id -un) must be in admin group for this machine to install tools"
if ! id -Gn | grep -e "\badmin\b" >/dev/null 2>&1; then
    _warn "You are not in admin group for this machine. First you must grant your user the permission to administer this machine. See README for how to Administer this computer first, and rerun this script again... EXITING SCRIPT"
    exit -1;
fi

_boot "CREATE: ~/.bash_profile_homebrewstrap"

if [ -f "$HOME/.bash_profile_homebrewstrap" ]; then
    _warn "Found existing file: ~/.bash_profile_homebrewstrap"
    _confirm_or_exit "You may want to examine that file contents first. Can we continue with recreating this file ?"
fi

_act "Creating ~/.bash_profile_homebrewstrap file and sourcing .bashrc, see...: http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html"

echo -e '# DO NOT EDIT. managed by homebrewstrap.sh \n# For macOS source bashrc from bash_profile\n[[ -e "$HOME/.bashrc" ]] && source "$HOME/.bashrc"' > "$HOME/.bash_profile_homebrewstrap"

_act "Adjusting PATH to favor homebrew installed tools"
echo 'export PATH="/usr/local/bin:/usr/local/sbin:$PATH" #favor homebrew installed tools' >> ~/.bash_profile_homebrewstrap

if cat "$HOME/.bash_profile" | grep bash_profile_homebrewstrap ; then
    _skip "Your ~/.bash_profile already has entry for ~/.bash_profile_homebrewstrap. Please verify that you source it correctly"
else
    _act "setting source ~/.bash_profile_homebrewstrap in your ~/.bash_profile"
    echo -e '\n# Managed by homebrewstrap.sh\nsource $HOME/.bash_profile_homebrewstrap' >> ~/.bash_profile
fi

_boot "Homebrew Package Manager"
_act "checking if brew is already installed"
if ! type -P brew >/dev/null 2>&1; then
    _act "installing homebrew package manager"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    _skip "homebrew is already installed"
fi

_boot "Use Homebrew to install or upgrade packages"
_act "Installing Sensible Developer Tools"
if _confirm_yes "Install tools listed in homebrewstrap.brewfile ?"; then
    brew bundle --file=homebrewstrap.brewfile
fi

_act "config bash-completion installed with brew"
echo '[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion' >> ~/.bash_profile_homebrewstrap

_boot "Java Programming Environment"
_info "This is a list of JDK versions currently available on this machine"
/usr/libexec/java_home --verbose

_act "java installation section"
if _confirm_yes "install latest java?"; then

    _act "Installing tools from java.brewfile"
    brew bundle --file=java.brewfile

    _act "adding JAVA_HOME to point to latest -- you can change it later to a diff version"
    echo -e '# JAVA_HOME shell homebrewstrap\nexport JAVA_HOME=$(/usr/libexec/java_home)' >> ~/.bash_profile_homebrewstrap

    _act "activating java by sourcing ~/.bash_profile"
    source "$HOME/.bash_profile"

    _info "This is a list of JDK versions currently available on this machine"
    /usr/libexec/java_home --verbose

    _info "displaying current bash session java version"
    java -version

fi # java

_boot "NodeJS Programming Envieronment"

if _confirm_yes "Install node with nvm? "; then

    _act "Installing nvm based on community recommendation, see...: https://github.com/creationix/nvm#installation"
    _info "Installing release: https://github.com/creationix/nvm/releases/tag/v0.34.0"
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

    _info "~/.nvm dir is now a git repo. Installation modified your ~/.bashrc"
    _act "Activating nvm by sourcing ~/.bash_profile"
    source "$HOME/.bash_profile"

    _act "Verify NVM installation. see...: https://github.com/creationix/nvm#verify-installation"
    if [[ $(command -v nvm) == nvm ]]
    then
        _info "nvm function available"
    else
        _warn "Unable to detect the presence of NVM. Next nvm commands may fail. "
    fi

    _act "Using NVM to install latest --lts"
    nvm install --lts
    _act "Using just installed Node as a default -- you can change it later"
    nvm alias default lts/*

fi # nodejs


_boot "Python3 with MINICONDA"

if _confirm_yes "install miniconda python? "; then

    _act "Installing tools from python.brewfile"
    brew bundle --file=python.brewfile

    _act "Adding /usr/local/anaconda/bin to PATH"
    echo -e '# PYTHON binaries PATH shell homebrewstrap\nexport PATH=/usr/local/miniconda3/bin:"$PATH"' >> ~/.bash_profile_homebrewstrap

    _act "Activating python by sourcing ~/bash_profile"
    source "$HOME/.bash_profile"

fi # python


_boot "Ruby with rbenv"
if _confirm_yes "install rbenv ruby environment? "; then

    _act "Checking for rvm installation. We will exit if rvm is already installed"
    if type -P rvm 2>/dev/null; then
        _warn "rvm is installed on this machine. rbenv and rvm can not coexist. exiting"
        _warn "please remove rvm with 'rvm implode' first and rerun this script again... EXITING SCRIPT"
        exit -1;
    fi

    _act "Installing tools from ruby.brewfile"
    brew bundle --file=ruby.brewfile

    _act "Adding rbenv init"
    # => your .bash_profile_homebrewstrap should have the following entry

    # # RBENV shell homebrewstrap
    # eval "$(rbenv init -)"
    echo -e '# RBENV shell homebrewstrap\neval "$(rbenv init -)"' >> ~/.bash_profile_homebrewstrap

    _act "Activating rbenv by sourcing ~/.bash_profile"
    source "$HOME/.bash_profile"

    # install ruby with rbenv ruby-build
    _boot "RUBY installation"
    ruby_version="2.5.3"
    _act "Installing ruby version $ruby_version"
    if ! rbenv versions | grep $ruby_version; then
        rbenv install $ruby_version
    else
        _skip "Ruby version $ruby_version already installed"
    fi
    _act "Setting global ruby version to: $ruby_version"
    rbenv global $ruby_version

    _act "Do not generate docs after installing gems. See ~/.gemrc"
    echo "gem: --no-document" > ~/.gemrc

    _act "Installing bundler and setting sensible configuration"
    gem install bundler --source https://rubygems.org/ -N
    number_of_cores=$(sysctl -n hw.ncpu)
    bundle config --global jobs $((number_of_cores - 1))


fi # ruby

_boot "DONE: Please review the README"
_info "You may execute brew cleanup && brew cask cleanup to do some housecleaning"
_info "Please examine ~/.bash_profile_homebrewstrap to see what we configured there. We source it from ~/.bash_profile"
_info "It is safe to rerun this script to install sections you have skipped BUT ONLY if you copy over the contents from ~/.bash_profile_homebrewstrap into ~/.bash_profile; since we will recreate ~/.bash_profile_homebrewstrap on each run"



# HomeBrewStrap: a throw away helper script

To automate the drudgery of manually setting up your macbook for software development

I assume you do not have `homebrew`, nor `git` installed 

The interactive `homebrewstrap.sh` script:
- installs `homebrew` package manager (http://brew.sh)
- installs sensible tools using `brew bundle`.
- install the following programming environments (after asking):
  - Java
  - NodeJS with `nvm`
  - Ruby with `rbenv`
  - Python 3 with `miniconda`

After you install `homebrew` on your MacBook you may remove this script from your machine, AND:
- use `brew bundle` to install or upgrade a list of tools from a personal, or a team managed `Brewfile`, see more...: https://github.com/Homebrew/homebrew-bundle
- use `brew install` to install command line tools
- use `brew cask install` to install a macOS application
- use `mas install` to install am App Store app; more...: https://github.com/mas-cli/mas    

# Installation

Perform the following steps:
1. You must be an be able to [administer this computer](#administer-this-computer)
2. [Download this repo's](#download-this-repo) latest .zip release package

## Administer this computer

I assume you, a currently logged in user, are and Administrator on this MacBook and you are the primary user. 
If you are not an Administrator then check with the Admin of the machine if you should proceed. 

## Download this repo

- Download the zip file of the latest release.
- Unzip it locally 
- and open a Terminal prompt inside the `homebrewstrap-vX.Y.Z` (note: x.y.z indicates a release version)

## Execute homebrewstrap.sh script

Execute the interactive `./homebrewstrap.sh` in your terminal.

Press ENTER to proceed or type `n` to skip a section.

## finalize installation

The `homebrewstrap.sh` script:
- creates `~/.bash_profile_homebrewstrap` file where it writes configurations for tools it installs, instead of polluting your primary `~/.bash_profile`
- sources `~/.bashrc` file. Some tools write their config into `~/.bashrc`. See...:http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html
- sources `~/.bash_profile_homebrewstrap` from `~/.bash_profile` which is loaded by bash session on macOS.

Troubleshooting:

You can leave your machine with  `~/.bash_profile_homebrewstrap` mechanism, but if you want to run this script again, then first copy over entries from `~/.bash_profile_homebrewstrap` into your `~/.bash_profile`. The is recreated on each run.

It's best to move over the configuration to your `~/.bash_profile`, and delete the generated `~/.bash_profile_homebrewstrap`, and this downloaded repo

I hope you find it useful 


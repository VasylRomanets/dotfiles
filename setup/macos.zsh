#!/bin/zsh

# sensible macOS defaults for a developer setup
# inspired by https://github.com/mathiasbynens/dotfiles/blob/master/.macos
#
# note: some settings require a logout/restart to take effect
# note: run this script on a fresh macOS install for best results

echo "applying macOS defaults..."

###############################################################################
# General                                                                     #
###############################################################################

# disable automatic capitalization (annoying when typing code)
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# disable smart dashes (annoying when typing code)
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# disable smart quotes (annoying when typing code)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# enable full keyboard access for all controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

###############################################################################
# Trackpad & Mouse                                                             #
###############################################################################

# enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

###############################################################################
# Finder                                                                      #
###############################################################################

# show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# show path bar
defaults write com.apple.finder ShowPathbar -bool true

# display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# use list view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

###############################################################################
# Dock                                                                        #
###############################################################################

# set the icon size to 48 pixels
defaults write com.apple.dock tilesize -int 48

# minimize windows into their application's icon
defaults write com.apple.dock minimize-to-application -bool true

# don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# remove the auto-hiding Dock delay
# defaults write com.apple.dock autohide-delay -float 0

# speed up the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0.5

###############################################################################
# Screenshots                                                                 #
###############################################################################

# save screenshots to Downloads
defaults write com.apple.screencapture location -string "${HOME}/Downloads"

# save screenshots in PNG format
defaults write com.apple.screencapture type -string "png"

# disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Software Updates                                                            #
###############################################################################

# check for updates daily
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# download updates in the background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# install security updates automatically
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

###############################################################################
# Kill affected apps                                                          #
###############################################################################

for app in "Finder" "Dock" "SystemUIServer"; do
  killall "${app}" &>/dev/null
done

echo "done — some settings may require a logout or restart to take effect"

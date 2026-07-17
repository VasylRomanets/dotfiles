#!/bin/zsh

# Sensible macOS defaults for a developer setup.
# Inspired by https://github.com/mathiasbynens/dotfiles/blob/master/.macos
#
# Note: some settings require a logout/restart to take effect.

SETUP_PATH="$(cd "$(dirname "$0")" && pwd)"
source "$SETUP_PATH/_lib.zsh"
require_macos

echo "Applying macOS defaults..."

###############################################################################
# General                                                                     #
###############################################################################

# disable automatic capitalization (annoying when typing code)
# defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# disable smart dashes (annoying when typing code)
# defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# disable automatic period substitution
# defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# disable smart quotes (annoying when typing code)
# defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# disable auto-correct
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# enable full keyboard access for all controls
# defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# expand save panel by default
# defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# expand print panel by default
# defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# always open documents in tabs instead of new windows
defaults write -g AppleWindowTabbingMode -string always

# disable crash reporter dialogs
defaults write com.apple.CrashReporter DialogType -string "none"

###############################################################################
# Appearance                                                                  #
###############################################################################

# replace app open/close animations with simple fade effect;
# requires full disk access for terminal
defaults write com.apple.universalaccess reduceMotion -bool true

# set accent color (5 = purple)
defaults write -g AppleAccentColor -int 5

###############################################################################
# Keyboard                                                                    #
###############################################################################

# disable press-and-hold (enables key repeat in all apps)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# set a fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2

# shorten the delay before key repeat kicks in
defaults write NSGlobalDomain InitialKeyRepeat -int 15

###############################################################################
# Trackpad & Mouse                                                             #
###############################################################################

# enable tap to click
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
# defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# enable three-finger drag
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
# defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# open new Finder windows to the home folder
defaults write com.apple.finder NewWindowTarget -string PfHm
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

# show status bar
# defaults write com.apple.finder ShowStatusBar -bool true

# show path bar
defaults write com.apple.finder ShowPathbar -bool true

# display full POSIX path as Finder window title
# defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# search the current folder by default
# defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# use list view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# remove items from Trash after 30 days
# defaults write com.apple.finder FXRemoveOldTrashItems -bool true

# keep the desktop clean by hiding disk icons
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

###############################################################################
# Dock                                                                        #
###############################################################################

# remove all persistent (pinned) apps from the Dock
defaults write com.apple.dock persistent-apps -array ""

# set the icon size to 56 pixels
defaults write com.apple.dock tilesize -int 56

# minimize windows into their application's icon
defaults write com.apple.dock minimize-to-application -bool true

# don't automatically rearrange Spaces based on most recent use
# defaults write com.apple.dock mru-spaces -bool false

# don't show recent apps in Dock
defaults write com.apple.dock show-recents -bool false

# automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# remove the auto-hiding Dock delay
# defaults write com.apple.dock autohide-delay -float 0

# speed up the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0.5

# disable hot corners
defaults write com.apple.dock wvous-tl-corner -int 1
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

###############################################################################
# Stage Manager                                                              #
###############################################################################

# enable Stage Manager
defaults write com.apple.WindowManager GloballyEnabled -bool true

# auto-hide recent apps
defaults write com.apple.WindowManager AutoHide -bool true

# the left-edge hover-to-reveal trigger for recent apps can't be disabled,
# but it can be delayed
defaults write com.apple.WindowManager AutoHideDelay -float 3.0

# remove the left/right inset Stage Manager adds when reopening a
# previously maximized window, so it fills the screen width again
defaults write com.apple.WindowManager StageFrameMinimumHorizontalInset -int 0

###############################################################################
# Privacy                                                                     #
###############################################################################

# disable Apple's ad personalization and tracking
defaults write com.apple.AdLib forceLimitAdTracking -bool true
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false

###############################################################################
# Screenshots                                                                 #
###############################################################################

# save screenshots to ~/Pictures/Screenshots
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"

# save screenshots in PNG format
# defaults write com.apple.screencapture type -string "png"

# disable shadow in screenshots
# defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Software Updates                                                            #
###############################################################################

# check for updates daily
# defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# download updates in the background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# install security updates automatically
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

###############################################################################
# TextEdit                                                                    #
###############################################################################

# use plain text mode for new documents
defaults write com.apple.TextEdit RichText -int 0

# open and save files as UTF-8
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

###############################################################################
# Touch ID                                                                    #
###############################################################################

# enable Touch ID for sudo (persists across macOS updates via sudo_local)
if [[ ! -f /etc/pam.d/sudo_local ]]; then
  sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
  sudo sed -i '' 's/#auth/auth/' /etc/pam.d/sudo_local
fi

###############################################################################
# Kill affected apps                                                          #
###############################################################################

for app in "Finder" "Dock" "SystemUIServer"; do
  killall "${app}" &>/dev/null
done

success "Done — some settings may require a logout or restart to take effect."

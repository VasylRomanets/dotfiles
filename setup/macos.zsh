#!/bin/zsh

# Sensible macOS defaults for a developer setup.
# Inspired by https://github.com/mathiasbynens/dotfiles/blob/master/.macos
#
# Note: some settings require a logout/restart to take effect.

SETUP_PATH="$(cd "$(dirname "$0")" && pwd)"
source "$SETUP_PATH/_lib.zsh"
require_macos

request_sudo

echo "Applying macOS defaults..."

# --- General ------------------------------------------------------------------
# Enable full keyboard access for all controls.
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Expand the save panel by default.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand the print panel by default.
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Always open documents in tabs instead of new windows.
defaults write -g AppleWindowTabbingMode -string always

# Save new documents locally by default, rather than to iCloud.
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Reopen an app's windows when relaunching it, rather than starting clean.
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true

# Show a crash reporter notification instead of a dialog.
defaults write com.apple.CrashReporter DialogType -string "notification"

# --- Language & Region --------------------------------------------------------
# Preferred language order and regional formatting (dates, numbers, etc.).
defaults write NSGlobalDomain AppleLanguages -array "en-UA" "uk-UA"
defaults write NSGlobalDomain AppleLocale -string "en_UA"

# --- Text Input ---------------------------------------------------------------
# Disable auto-correct.
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable automatic text completion.
defaults write NSGlobalDomain NSAutomaticTextCompletionEnabled -bool false

# Disable automatic capitalization.
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes.
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable smart quotes.
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable automatic period substitution.
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Enable inline predictive text (unlike the above, this only suggests — it
# doesn't silently rewrite what you type).
defaults write NSGlobalDomain NSAutomaticInlinePredictionEnabled -bool true

# --- Appearance ---------------------------------------------------------------
# Replace app open/close animations with a simple fade effect;
# requires full disk access for Terminal.
defaults write com.apple.universalaccess reduceMotion -bool true

# Set the accent color (5 = purple).
defaults write -g AppleAccentColor -int 5

# Always show scrollbars, rather than only while scrolling.
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Switch between Light and Dark mode automatically with time of day.
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

# Open Quick Look previews instantly, without the zoom animation.
defaults write NSGlobalDomain QLPanelAnimationDuration -float 0

# --- Keyboard -----------------------------------------------------------------
# Disable press-and-hold (enables key repeat in all apps).
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a fast key repeat rate.
defaults write NSGlobalDomain KeyRepeat -int 2

# Shorten the delay before key repeat kicks in.
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Use F1, F2, etc. as standard function keys, rather than their media/feature shortcuts.
# defaults write NSGlobalDomain "com.apple.keyboard.fnState" -bool true

# --- Trackpad & Mouse ---------------------------------------------------------
# Enable natural scrolling direction.
defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool true

# Enable tap to click.
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
# defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Enable three-finger drag.
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
# defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# --- Finder -------------------------------------------------------------------
# Disable window open/close and Get Info animations.
defaults write com.apple.finder DisableAllAnimations -bool true

# Show all file extensions.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show hidden files by default.
defaults write com.apple.finder AppleShowAllFiles -bool true

# Open new Finder windows to the home folder.
defaults write com.apple.finder NewWindowTarget -string PfHm
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

# Hide the status bar.
defaults write com.apple.finder ShowStatusBar -bool false

# Show the path bar.
defaults write com.apple.finder ShowPathbar -bool true

# Display the full POSIX path as the Finder window title.
# defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name.
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Search the current folder by default.
# defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension.
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Spring-load folders and the Dock: dragging a file over one for a moment
# opens it automatically, so you can drill into subfolders mid-drag.
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network or USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default.
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Remove items from Trash after 30 days.
# defaults write com.apple.finder FXRemoveOldTrashItems -bool true

# Keep the desktop clean by hiding disk icons.
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

# --- Dock ---------------------------------------------------------------------
# Remove all persistent (pinned) apps from the Dock.
defaults write com.apple.dock persistent-apps -array ""

# Show only currently running apps in the Dock.
defaults write com.apple.dock static-only -bool true

# Set the icon size and magnification.
defaults write com.apple.dock tilesize -int 60
defaults write com.apple.dock largesize -int 70
defaults write com.apple.dock magnification -bool true

# Minimize windows into their application's icon.
defaults write com.apple.dock minimize-to-application -bool true

# Disable the bouncy animation when launching an app.
# defaults write com.apple.dock launchanim -bool false

# Group windows by application in Mission Control.
defaults write com.apple.dock expose-group-apps -bool true

# Speed up Mission Control's animations.
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don't automatically rearrange Spaces based on most recent use.
# defaults write com.apple.dock mru-spaces -bool false

# Don't show recent apps in the Dock.
defaults write com.apple.dock show-recents -bool false

# Automatically hide and show the Dock.
defaults write com.apple.dock autohide -bool true

# Remove the auto-hiding Dock delay.
# defaults write com.apple.dock autohide-delay -float 0

# Speed up the animation when hiding/showing the Dock.
defaults write com.apple.dock autohide-time-modifier -float 0.5

# Disable hot corners.
defaults write com.apple.dock wvous-tl-corner -int 1
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

# --- Menu Bar -----------------------------------------------------------------
# Hide AM/PM, use 24-hour format, show the day of week and date.
defaults write com.apple.menuextra.clock ShowAMPM -bool false
defaults write com.apple.menuextra.clock Show24Hour -bool true
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowDate -int 1

# Show the battery percentage.
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true

# Remove Siri from the menu bar.
defaults write com.apple.Siri StatusMenuVisible -bool false

# Disable "Hey Siri" voice activation.
defaults write com.apple.Siri VoiceTriggerUserEnabled -bool false

# --- Stage Manager ------------------------------------------------------------
# Enable Stage Manager.
defaults write com.apple.WindowManager GloballyEnabled -bool true

# Auto-hide recent apps.
defaults write com.apple.WindowManager AutoHide -bool true

# The left-edge hover-to-reveal trigger for recent apps can't be disabled,
# but it can be delayed.
defaults write com.apple.WindowManager AutoHideDelay -float 3.0

# Remove the left/right inset Stage Manager adds when reopening a
# previously maximized window, so it fills the screen width again.
defaults write com.apple.WindowManager StageFrameMinimumHorizontalInset -int 0

# Hide widgets on the desktop.
defaults write com.apple.WindowManager StandardHideWidgets -bool true
defaults write com.apple.WindowManager StageManagerHideWidgets -bool true

# Always allow clicking the wallpaper to reveal the desktop, not just in Stage Manager.
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool true

# Group all of an app's windows together, rather than one at a time.
defaults write com.apple.WindowManager AppWindowGroupingBehavior -bool true

# --- Privacy & Security -------------------------------------------------------
# Disable Apple's ad personalization and tracking.
defaults write com.apple.AdLib forceLimitAdTracking -bool true
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false

# Show a custom message on the login window / lock screen.
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText \
    -string "Contact romanets.vasyl@gmail.com if you found this MacBook"

# Disable the Guest User account.
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false

# Start the screen saver after 2 minutes of inactivity.
defaults -currentHost write com.apple.screensaver idleTime -int 120

# Require a password immediately after sleep or the screen saver starts.
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# --- Screenshots --------------------------------------------------------------
# Save screenshots to ~/Pictures/Screenshots.
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"

# Save screenshots in PNG format.
# defaults write com.apple.screencapture type -string "png"

# Disable the shadow in screenshots.
# defaults write com.apple.screencapture disable-shadow -bool true

# --- Software Updates ---------------------------------------------------------
# Check for updates daily.
# defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download updates in the background.
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install security updates automatically.
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# --- Sound --------------------------------------------------------------------
# Mute the feedback sound when changing the system volume.
defaults write NSGlobalDomain "com.apple.sound.beep.feedback" -int 0

# --- Calendar -----------------------------------------------------------------
# Start the week on Monday.
defaults write com.apple.iCal "first day of week" -int 2

# --- TextEdit -----------------------------------------------------------------
# Use plain text mode for new documents.
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8.
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# --- Touch ID -----------------------------------------------------------------
# Enable Touch ID for sudo (persists across macOS updates via sudo_local).
if [[ ! -f /etc/pam.d/sudo_local ]]; then
  sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
  sudo sed -i '' 's/#auth/auth/' /etc/pam.d/sudo_local
fi

# --- Kill affected apps -------------------------------------------------------
for app in "Finder" "Dock" "SystemUIServer" "ControlCenter"; do
  killall "${app}" &>/dev/null
done

success "Done — some settings may require a logout or restart to take effect."

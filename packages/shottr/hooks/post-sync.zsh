#!/usr/bin/env zsh

# Free Cmd+Shift+3 and 4 and their Ctrl variants (copy to clipboard) for
# Shottr. Cmd+Shift+5 stays with macOS.
for id in 28 29 30 31; do
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
    -dict-add $id '<dict><key>enabled</key><false/></dict>'
done

# Make macOS re-read the shortcuts without a logout.
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

# Global hotkeys, stored by Shottr as JSON with Carbon key codes. The codes 18
# to 21 are the 1 to 4 keys, and 768 is Cmd (256) plus Shift (512). Shottr
# reads them at launch, so restart it after a sync that changes them.
defaults write cc.ffitch.shottr KeyboardShortcuts_window -string '{"carbonKeyCode":18,"carbonModifiers":768}'
defaults write cc.ffitch.shottr KeyboardShortcuts_ocr -string '{"carbonKeyCode":19,"carbonModifiers":768}'
defaults write cc.ffitch.shottr KeyboardShortcuts_fullscreen -string '{"carbonKeyCode":20,"carbonModifiers":768}'
defaults write cc.ffitch.shottr KeyboardShortcuts_area -string '{"carbonKeyCode":21,"carbonModifiers":768}'

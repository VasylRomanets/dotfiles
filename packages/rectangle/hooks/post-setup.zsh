#!/usr/bin/env zsh

# almost-maximize resizes to 90% of the screen (height and width), centered.
# This matches Rectangle's own built-in default when unset, but is written
# explicitly so it doesn't silently depend on that default.
defaults write com.knollsoft.Rectangle almostMaximizeHeight -float 0.9
defaults write com.knollsoft.Rectangle almostMaximizeWidth -float 0.9

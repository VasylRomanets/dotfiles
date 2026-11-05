#!/usr/bin/env zsh

# Compile the Swift source to a native binary on PATH

pkg_dir="${0:A:h:h}"
mkdir -p "$HOME/.local/bin"
swiftc -O "$pkg_dir/finder-focus.swift" -o "$HOME/.local/bin/finder-focus"

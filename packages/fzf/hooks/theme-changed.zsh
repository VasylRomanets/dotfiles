#!/usr/bin/env zsh

# Reacts to theme-set (see setup/sync.zsh): writes the matching color block
# to the file fzf-core.zsh points FZF_DEFAULT_OPTS_FILE at — fzf reads it
# fresh on every invocation, no shell-level reactivity needed.
theme=$1

fzf_rose_pine="
  --color=fg:#908caa,bg:#191724,hl:#ebbcba
  --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
  --color=border:#403d52,header:#31748f,gutter:#191724
  --color=spinner:#f6c177,info:#9ccfd8
  --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

fzf_rose_pine_dawn="
  --color=fg:#797593,bg:#faf4ed,hl:#d7827e
  --color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e
  --color=border:#dfdad9,header:#286983,gutter:#faf4ed
  --color=spinner:#ea9d34,info:#56949f
  --color=pointer:#907aa9,marker:#b4637a,prompt:#797593"

fzf_rose_pine_moon="
  --color=fg:#908caa,bg:#232136,hl:#ea9a97
  --color=fg+:#e0def4,bg+:#393552,hl+:#ea9a97
  --color=border:#44415a,header:#3e8fb0,gutter:#232136
  --color=spinner:#f6c177,info:#9ccfd8
  --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

fzf_kanagawa_wave="
  --color=fg:#727169,bg:#1f1f28,hl:#7e9cd8
  --color=fg+:#dcd7ba,bg+:#2d4f67,hl+:#7fb4ca
  --color=border:#727169,header:#6a9589,gutter:#1f1f28
  --color=spinner:#c0a36e,info:#6a9589
  --color=pointer:#957fb8,marker:#e82424,prompt:#727169"

fzf_nord="
  --color=fg:#a5abb6,bg:#2e3440,hl:#88c0d0
  --color=fg+:#d8dee9,bg+:#4c566a,hl+:#8fbcbb
  --color=border:#4c566a,header:#81a1c1,gutter:#2e3440
  --color=spinner:#ebcb8b,info:#88c0d0
  --color=pointer:#b48ead,marker:#bf616a,prompt:#a5abb6"

fzf_everforest_dark_hard="
  --color=fg:#7a8478,bg:#272e33,hl:#a7c080
  --color=fg+:#d3c6aa,bg+:#2e383c,hl+:#a7c080
  --color=border:#7a8478,header:#7fbbb3,gutter:#272e33
  --color=spinner:#dbbc7f,info:#83c092
  --color=pointer:#d699b6,marker:#e67e80,prompt:#7a8478"

fzf_duskfox="
  --color=fg:#817c9c,bg:#232136,hl:#eb98c3
  --color=fg+:#e0def4,bg+:#373354,hl+:#eb98c3
  --color=border:#4b4673,header:#569fba,gutter:#232136
  --color=spinner:#f6c177,info:#9ccfd8
  --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#817c9c"

fzf_catppuccin_latte="
  --color=fg:#4c4f69,bg:#eff1f5,hl:#d20f39
  --color=fg+:#4c4f69,bg+:#ccd0da,hl+:#d20f39
  --color=border:#9ca0b0,header:#d20f39,gutter:#eff1f5
  --color=spinner:#dc8a78,info:#8839ef
  --color=pointer:#dc8a78,marker:#7287fd,prompt:#8839ef"

fzf_catppuccin_frappe="
  --color=fg:#c6d0f5,bg:#303446,hl:#e78284
  --color=fg+:#c6d0f5,bg+:#414559,hl+:#e78284
  --color=border:#737994,header:#e78284,gutter:#303446
  --color=spinner:#f2d5cf,info:#ca9ee6
  --color=pointer:#f2d5cf,marker:#babbf1,prompt:#ca9ee6"

fzf_catppuccin_macchiato="
  --color=fg:#cad3f5,bg:#24273a,hl:#ed8796
  --color=fg+:#cad3f5,bg+:#363a4f,hl+:#ed8796
  --color=border:#6e738d,header:#ed8796,gutter:#24273a
  --color=spinner:#f4dbd6,info:#c6a0f6
  --color=pointer:#f4dbd6,marker:#b7bdf8,prompt:#c6a0f6"

fzf_catppuccin_mocha="
  --color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8
  --color=fg+:#cdd6f4,bg+:#313244,hl+:#f38ba8
  --color=border:#6c7086,header:#f38ba8,gutter:#1e1e2e
  --color=spinner:#f5e0dc,info:#cba6f7
  --color=pointer:#f5e0dc,marker:#b4befe,prompt:#cba6f7"

fzf_tokyonight_night="
  --color=fg:#c0caf5,bg:#16161e,hl:#2ac3de
  --color=fg+:#c0caf5,bg+:#283457,hl+:#2ac3de
  --color=border:#27a1b9,header:#ff9e64,gutter:#16161e
  --color=spinner:#ff007c,info:#545c7e
  --color=pointer:#ff007c,marker:#ff007c,prompt:#2ac3de"

fzf_tokyonight_storm="
  --color=fg:#c0caf5,bg:#1f2335,hl:#2ac3de
  --color=fg+:#c0caf5,bg+:#2e3c64,hl+:#2ac3de
  --color=border:#29a4bd,header:#ff9e64,gutter:#1f2335
  --color=spinner:#ff007c,info:#545c7e
  --color=pointer:#ff007c,marker:#ff007c,prompt:#2ac3de"

fzf_tokyonight_moon="
  --color=fg:#c8d3f5,bg:#1e2030,hl:#65bcff
  --color=fg+:#c8d3f5,bg+:#2d3f76,hl+:#65bcff
  --color=border:#589ed7,header:#ff966c,gutter:#1e2030
  --color=spinner:#ff007c,info:#545c7e
  --color=pointer:#ff007c,marker:#ff007c,prompt:#65bcff"

fzf_tokyonight_day="
  --color=fg:#3760bf,bg:#d0d5e3,hl:#188092
  --color=fg+:#3760bf,bg+:#b7c1e3,hl+:#188092
  --color=border:#4094a3,header:#b15c00,gutter:#d0d5e3
  --color=spinner:#d20065,info:#8990b3
  --color=pointer:#d20065,marker:#d20065,prompt:#188092"

fzf_miasma="
  --color=fg:#666666,bg:#222222,hl:#bb7744
  --color=fg+:#c2c2b0,bg+:#1c1c1c,hl+:#bb7744
  --color=border:#666666,header:#5f875f,gutter:#222222
  --color=spinner:#b36d43,info:#c9a554
  --color=pointer:#bb7744,marker:#b36d43,prompt:#666666"

fzf_kanagawa_dragon="
  --color=fg:#737c73,bg:#181616,hl:#c4746e
  --color=fg+:#c5c9c5,bg+:#282727,hl+:#c4746e
  --color=border:#7a8382,header:#8ea4a2,gutter:#181616
  --color=spinner:#b6927b,info:#8ba4b0
  --color=pointer:#8992a7,marker:#e82424,prompt:#737c73"

fzf_kanagawa_lotus="
  --color=fg:#8a8980,bg:#f2ecbc,hl:#c84053
  --color=fg+:#545464,bg+:#e7dba0,hl+:#c84053
  --color=border:#766b90,header:#597b75,gutter:#f2ecbc
  --color=spinner:#cc6d00,info:#4d699b
  --color=pointer:#624c83,marker:#e82424,prompt:#8a8980"

fzf_ember="
  --color=fg:#706c61,bg:#1c1b19,hl:#e08060
  --color=fg+:#d8d0c0,bg+:#242320,hl+:#e08060
  --color=border:#908a7e,header:#7890a0,gutter:#1c1b19
  --color=spinner:#c8b468,info:#7890a0
  --color=pointer:#e08060,marker:#b07878,prompt:#706c61"

fzf_ember_soft="
  --color=fg:#706c61,bg:#242320,hl:#e08060
  --color=fg+:#d8d0c0,bg+:#2a2927,hl+:#e08060
  --color=border:#908a7e,header:#7890a0,gutter:#242320
  --color=spinner:#c8b468,info:#7890a0
  --color=pointer:#e08060,marker:#b07878,prompt:#706c61"

fzf_ember_light="
  --color=fg:#787060,bg:#e6dac4,hl:#b84c30
  --color=fg+:#282418,bg+:#ddd0b8,hl+:#b84c30
  --color=border:#605848,header:#3a6080,gutter:#e6dac4
  --color=spinner:#7a6820,info:#3a6080
  --color=pointer:#b84c30,marker:#905050,prompt:#787060"

fzf_sora="
  --color=fg:#c8d0e0,bg:#0e1018,hl:#80c8e0
  --color=fg+:#dce4f0,bg+:#1e2430,hl+:#98d8f0
  --color=border:#364050,header:#80c8e0,gutter:#0e1018
  --color=spinner:#80c8e0,info:#586478
  --color=pointer:#80c8e0,marker:#90c8a0,prompt:#b0a0d8"

fzf_noctis="
  --color=fg:#b2cacd,bg:#052529,hl:#49d6e9
  --color=fg+:#c1d4d7,bg+:#0f3a3f,hl+:#60b6eb
  --color=border:#2b494d,header:#49d6e9,gutter:#052529
  --color=spinner:#49d6e9,info:#5b858b
  --color=pointer:#49d6e9,marker:#49e9a6,prompt:#df769b"

fzf_noctis_azureus="
  --color=fg:#becfda,bg:#07273b,hl:#49d6e9
  --color=fg+:#becfda,bg+:#103850,hl+:#60b6eb
  --color=border:#2f4c5e,header:#49d6e9,gutter:#07273b
  --color=spinner:#49d6e9,info:#5988a6
  --color=pointer:#49d6e9,marker:#49e9a6,prompt:#df769b"

fzf_noctis_bordo="
  --color=fg:#cbbec2,bg:#322a2d,hl:#49d6e9
  --color=fg+:#cbbec2,bg+:#4a3339,hl+:#60b6eb
  --color=border:#544b4e,header:#49d6e9,gutter:#322a2d
  --color=spinner:#49d6e9,info:#8b747c
  --color=pointer:#49d6e9,marker:#49e9a6,prompt:#df769b"

fzf_noctis_hibernus="
  --color=fg:#005661,bg:#f4f6f6,hl:#00bdd6
  --color=fg+:#003c44,bg+:#d9e0e0,hl+:#0fa3ff
  --color=border:#bed3d5,header:#00bdd6,gutter:#f4f6f6
  --color=spinner:#00bdd6,info:#8ca6a6
  --color=pointer:#00bdd6,marker:#00b368,prompt:#ff5792"

fzf_noctis_lilac="
  --color=fg:#0c006b,bg:#f2f1f8,hl:#00bdd6
  --color=fg+:#08004b,bg+:#d5d3e5,hl+:#0fa3ff
  --color=border:#bfbcd9,header:#00bdd6,gutter:#f2f1f8
  --color=spinner:#00bdd6,info:#9995b7
  --color=pointer:#00bdd6,marker:#00b368,prompt:#ff5792"

fzf_noctis_lux="
  --color=fg:#005661,bg:#fef8ec,hl:#00bdd6
  --color=fg+:#003c44,bg+:#f4e2b8,hl+:#0fa3ff
  --color=border:#c6d4cd,header:#00bdd6,gutter:#fef8ec
  --color=spinner:#00bdd6,info:#8ca6a6
  --color=pointer:#00bdd6,marker:#00b368,prompt:#ff5792"

fzf_noctis_minimus="
  --color=fg:#c5cdd3,bg:#1b2932,hl:#72b7c0
  --color=fg+:#c5d1d3,bg+:#263c4a,hl+:#68a4ca
  --color=border:#404d55,header:#72b7c0,gutter:#1b2932
  --color=spinner:#72b7c0,info:#5e7887
  --color=pointer:#72b7c0,marker:#72c09f,prompt:#c28097"

fzf_noctis_obscuro="
  --color=fg:#b2cacd,bg:#031417,hl:#49d6e9
  --color=fg+:#c1d4d7,bg+:#0d2a2f,hl+:#60b6eb
  --color=border:#2a3c3f,header:#49d6e9,gutter:#031417
  --color=spinner:#49d6e9,info:#5b858b
  --color=pointer:#49d6e9,marker:#49e9a6,prompt:#df769b"

fzf_noctis_sereno="
  --color=fg:#b2cacd,bg:#062e32,hl:#49d6e9
  --color=fg+:#c1d4d7,bg+:#0f4045,hl+:#60b6eb
  --color=border:#2c5054,header:#49d6e9,gutter:#062e32
  --color=spinner:#49d6e9,info:#5b858b
  --color=pointer:#49d6e9,marker:#49e9a6,prompt:#df769b"

fzf_noctis_uva="
  --color=fg:#c5c2d6,bg:#292640,hl:#49d6e9
  --color=fg+:#c5c2d6,bg+:#35325a,hl+:#60b6eb
  --color=border:#4b4861,header:#49d6e9,gutter:#292640
  --color=spinner:#49d6e9,info:#716c93
  --color=pointer:#49d6e9,marker:#49e9a6,prompt:#df769b"

fzf_noctis_viola="
  --color=fg:#ccbfd9,bg:#30243d,hl:#49d6e9
  --color=fg+:#ccbfd9,bg+:#3e3352,hl+:#60b6eb
  --color=border:#52465f,header:#49d6e9,gutter:#30243d
  --color=spinner:#49d6e9,info:#7f659a
  --color=pointer:#49d6e9,marker:#49e9a6,prompt:#df769b"

fzf_nord_wave="
  --color=fg:#d8dee9,bg:#212121,hl:#88c0d0
  --color=fg+:#eceff4,bg+:#373839,hl+:#88c0d0
  --color=border:#494b4d,header:#88c0d0,gutter:#212121
  --color=spinner:#88c0d0,info:#6a6d71
  --color=pointer:#88c0d0,marker:#a3be8c,prompt:#b48ead"

fzf_tomorrow="
  --color=fg:#4d4d4c,bg:#ffffff,hl:#3e999f
  --color=fg+:#363635,bg+:#d6d6d6,hl+:#3e999f
  --color=border:#d8d8d8,header:#3e999f,gutter:#ffffff
  --color=spinner:#3e999f,info:#8e908c
  --color=pointer:#3e999f,marker:#718c00,prompt:#8959a8"

fzf_tomorrow_night="
  --color=fg:#c5c8c6,bg:#1d1f21,hl:#8abeb7
  --color=fg+:#ffffff,bg+:#373b41,hl+:#8abeb7
  --color=border:#424445,header:#8abeb7,gutter:#1d1f21
  --color=spinner:#8abeb7,info:#969896
  --color=pointer:#8abeb7,marker:#b5bd68,prompt:#b294bb"

fzf_tomorrow_night_blue="
  --color=fg:#ffffff,bg:#002451,hl:#99ffff
  --color=fg+:#ffffff,bg+:#003f8e,hl+:#99ffff
  --color=border:#385477,header:#99ffff,gutter:#002451
  --color=spinner:#99ffff,info:#7285b7
  --color=pointer:#99ffff,marker:#d1f1a9,prompt:#ebbbff"

fzf_tomorrow_night_bright="
  --color=fg:#eaeaea,bg:#000000,hl:#70c0b1
  --color=fg+:#ffffff,bg+:#424242,hl+:#70c0b1
  --color=border:#333333,header:#70c0b1,gutter:#000000
  --color=spinner:#70c0b1,info:#969896
  --color=pointer:#70c0b1,marker:#b9ca4a,prompt:#c397d8"

fzf_tomorrow_night_eighties="
  --color=fg:#cccccc,bg:#2d2d2d,hl:#66cccc
  --color=fg+:#ffffff,bg+:#515151,hl+:#66cccc
  --color=border:#505050,header:#66cccc,gutter:#2d2d2d
  --color=spinner:#66cccc,info:#999999
  --color=pointer:#66cccc,marker:#99cc99,prompt:#cc99cc"

fzf_birds_of_paradise="
  --color=fg:#e0dbb7,bg:#2a1f1d,hl:#74a6ad
  --color=fg+:#fff9d5,bg+:#563c27,hl+:#74a6ad
  --color=border:#52483f,header:#74a6ad,gutter:#2a1f1d
  --color=spinner:#74a6ad,info:#9b6c4a
  --color=pointer:#74a6ad,marker:#6ba18a,prompt:#ac80a6"

fzf_no_clown_fiesta="
  --color=fg:#e0e1e4,bg:#101010,hl:#88afa2
  --color=fg+:#afafaf,bg+:#696d79,hl+:#88afa2
  --color=border:#3e3e3f,header:#88afa2,gutter:#101010
  --color=spinner:#88afa2,info:#727272
  --color=pointer:#88afa2,marker:#90a959,prompt:#aa759f"

fzf_no_clown_fiesta_light="
  --color=fg:#151515,bg:#e1e1e1,hl:#3e5f66
  --color=fg+:#0f0f0f,bg+:#c6d5de,hl+:#3e5f66
  --color=border:#b4b4b4,header:#3e5f66,gutter:#e1e1e1
  --color=spinner:#3e5f66,info:#2b2b2b
  --color=pointer:#3e5f66,marker:#677940,prompt:#aa759f"

fzf_kanso_ink="
  --color=fg:#c5c9c7,bg:#14171d,hl:#8ea4a2
  --color=fg+:#c5c9c7,bg+:#3E424A,hl+:#8ea4a2
  --color=border:#3b3e42,header:#8ea4a2,gutter:#14171d
  --color=spinner:#8ea4a2,info:#5C6066
  --color=pointer:#8ea4a2,marker:#8a9a7b,prompt:#a292a3"

fzf_kanso_mist="
  --color=fg:#c5c9c7,bg:#23262D,hl:#8ea4a2
  --color=fg+:#c5c9c7,bg+:#43464E,hl+:#8ea4a2
  --color=border:#474a4f,header:#8ea4a2,gutter:#23262D
  --color=spinner:#8ea4a2,info:#5C6066
  --color=pointer:#8ea4a2,marker:#8a9a7b,prompt:#a292a3"

fzf_kanso_pearl="
  --color=fg:#22262D,bg:#f2f1ef,hl:#597b75
  --color=fg+:#181b1f,bg+:#e2e1df,hl+:#597b75
  --color=border:#c4c4c4,header:#597b75,gutter:#f2f1ef
  --color=spinner:#597b75,info:#5C6066
  --color=pointer:#597b75,marker:#6f894e,prompt:#b35b79"

fzf_kanso_zen="
  --color=fg:#c5c9c7,bg:#090E13,hl:#8ea4a2
  --color=fg+:#c5c9c7,bg+:#22262D,hl+:#8ea4a2
  --color=border:#32373b,header:#8ea4a2,gutter:#090E13
  --color=spinner:#8ea4a2,info:#5C6066
  --color=pointer:#8ea4a2,marker:#8a9a7b,prompt:#a292a3"

fzf_vesper="
  --color=fg:#ffffff,bg:#101010,hl:#ea83a5
  --color=fg+:#ffffff,bg+:#313131,hl+:#ea83a5
  --color=border:#454545,header:#ea83a5,gutter:#101010
  --color=spinner:#ea83a5,info:#707070
  --color=pointer:#ea83a5,marker:#90b99f,prompt:#e29eca"

fzf_tundra_arctic="
  --color=fg:#D1D5DB,bg:#111827,hl:#BAE6FD
  --color=fg+:#dfe2e6,bg+:#374151,hl+:#BAE6FD
  --color=border:#3b424f,header:#BAE6FD,gutter:#111827
  --color=spinner:#BAE6FD,info:#6B7280
  --color=pointer:#BAE6FD,marker:#B5E8B0,prompt:#DDD6FE"

fzf_tundra_jungle="
  --color=fg:#D1D5DB,bg:#1C1C1C,hl:#ACD5FC
  --color=fg+:#dfe2e6,bg+:#444444,hl+:#ACD5FC
  --color=border:#444546,header:#ACD5FC,gutter:#1C1C1C
  --color=spinner:#ACD5FC,info:#767676
  --color=pointer:#ACD5FC,marker:#AFD7AF,prompt:#D7D7FF"

fzf_dark_funeral="
  --color=fg:#c1c1c1,bg:#000000,hl:#d0dfee
  --color=fg+:#c1c1c1,bg+:#000000,hl+:#d0dfee
  --color=border:#303030,header:#999999,gutter:#000000
  --color=spinner:#999999,info:#505050
  --color=pointer:#c1c1c1,marker:#999999,prompt:#d0dfee"

fzf_impaled_nazarene="
  --color=fg:#c1c1c1,bg:#000000,hl:#B29740
  --color=fg+:#c1c1c1,bg+:#000000,hl+:#B29740
  --color=border:#303030,header:#999999,gutter:#000000
  --color=spinner:#999999,info:#505050
  --color=pointer:#c1c1c1,marker:#999999,prompt:#B29740"

case "$theme" in
  rose-pine) opts="$fzf_rose_pine" ;;
  rose-pine-moon) opts="$fzf_rose_pine_moon" ;;
  rose-pine-dawn) opts="$fzf_rose_pine_dawn" ;;
  kanagawa-wave) opts="$fzf_kanagawa_wave" ;;
  nord) opts="$fzf_nord" ;;
  everforest-dark-hard) opts="$fzf_everforest_dark_hard" ;;
  duskfox) opts="$fzf_duskfox" ;;
  catppuccin-latte) opts="$fzf_catppuccin_latte" ;;
  catppuccin-frappe) opts="$fzf_catppuccin_frappe" ;;
  catppuccin-macchiato) opts="$fzf_catppuccin_macchiato" ;;
  catppuccin-mocha) opts="$fzf_catppuccin_mocha" ;;
  tokyonight-night) opts="$fzf_tokyonight_night" ;;
  tokyonight-storm) opts="$fzf_tokyonight_storm" ;;
  tokyonight-moon) opts="$fzf_tokyonight_moon" ;;
  tokyonight-day) opts="$fzf_tokyonight_day" ;;
  miasma) opts="$fzf_miasma" ;;
  kanagawa-dragon) opts="$fzf_kanagawa_dragon" ;;
  kanagawa-lotus) opts="$fzf_kanagawa_lotus" ;;
  ember) opts="$fzf_ember" ;;
  ember-soft) opts="$fzf_ember_soft" ;;
  ember-light) opts="$fzf_ember_light" ;;
  sora) opts="$fzf_sora" ;;
  noctis) opts="$fzf_noctis" ;;
  noctis-azureus) opts="$fzf_noctis_azureus" ;;
  noctis-bordo) opts="$fzf_noctis_bordo" ;;
  noctis-hibernus) opts="$fzf_noctis_hibernus" ;;
  noctis-lilac) opts="$fzf_noctis_lilac" ;;
  noctis-lux) opts="$fzf_noctis_lux" ;;
  noctis-minimus) opts="$fzf_noctis_minimus" ;;
  noctis-obscuro) opts="$fzf_noctis_obscuro" ;;
  noctis-sereno) opts="$fzf_noctis_sereno" ;;
  noctis-uva) opts="$fzf_noctis_uva" ;;
  noctis-viola) opts="$fzf_noctis_viola" ;;
  nord-wave) opts="$fzf_nord_wave" ;;
  tomorrow-night-eighties) opts="$fzf_tomorrow_night_eighties" ;;
  birds-of-paradise) opts="$fzf_birds_of_paradise" ;;
  no-clown-fiesta-light) opts="$fzf_no_clown_fiesta_light" ;;
  kanso-zen) opts="$fzf_kanso_zen" ;;
  vesper) opts="$fzf_vesper" ;;
  tundra-jungle) opts="$fzf_tundra_jungle" ;;
  tundra-arctic) opts="$fzf_tundra_arctic" ;;
  kanso-pearl) opts="$fzf_kanso_pearl" ;;
  kanso-mist) opts="$fzf_kanso_mist" ;;
  kanso-ink) opts="$fzf_kanso_ink" ;;
  no-clown-fiesta) opts="$fzf_no_clown_fiesta" ;;
  tomorrow-night-bright) opts="$fzf_tomorrow_night_bright" ;;
  tomorrow-night-blue) opts="$fzf_tomorrow_night_blue" ;;
  tomorrow-night) opts="$fzf_tomorrow_night" ;;
  tomorrow) opts="$fzf_tomorrow" ;;
esac

theme_conf="${XDG_STATE_HOME:-$HOME/.local/state}/theme/generated/fzf.conf"
mkdir -p "${theme_conf:h}"
printf '%s\n' "$opts" >"$theme_conf"

# Everforest Dark Hard colors for eza
# https://github.com/eza-community/eza/blob/main/man/eza_colors.5.md
# https://github.com/sainnhe/everforest

EZA_COLORS=""

# reset defaults first
EZA_COLORS+="reset:"

# file types
EZA_COLORS+="di=34;1:" # directories — blue bold
EZA_COLORS+="ex=32:"   # executable files — green (#a7c080)
EZA_COLORS+="ln=36:"   # symlinks — teal (#7fbbb3)
EZA_COLORS+="or=31:"   # broken symlinks — red (#e67e80)
EZA_COLORS+="fi=0:"    # regular files — default

# special files
EZA_COLORS+="do=32:"    # documents — green
EZA_COLORS+="*.md=32:"  # markdown — green
EZA_COLORS+="co=35:"    # archives — magenta (#d699b6)
EZA_COLORS+="*.zip=35:" # zip archives — magenta
EZA_COLORS+="tm=90:"    # temporary files — grey
EZA_COLORS+="cm=90:"    # cmake files — grey
EZA_COLORS+=".*=90:"    # hidden files — grey

# timestamps
EZA_COLORS+="da=36:" # dates — teal

# permissions — keep minimal, no noise
EZA_COLORS+="ur=0:uw=0:ux=0:ue=0:" # user permissions
EZA_COLORS+="gr=0:gw=0:gx=0:"      # group permissions
EZA_COLORS+="tr=0:tw=0:tx=0:"      # other permissions
EZA_COLORS+="xa=0:"                # extended attribute marker

# punctuation and size
EZA_COLORS+="xx=90:" # punctuation ('-') — grey
EZA_COLORS+="nb=90:" # files under 1 KB — grey
EZA_COLORS+="nk=90:" # files under 1 MB — grey
EZA_COLORS+="nm=37:" # files under 1 GB — white
EZA_COLORS+="ng=97:" # files under 1 TB — bright white
EZA_COLORS+="nt=97:" # files over 1 TB — bright white

export EZA_COLORS

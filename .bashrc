#    _               _              
#   | |__   __ _ ___| |__  _ __ ___ 
#   | '_ \ / _` / __| '_ \| '__/ __|
#  _| |_) | (_| \__ \ | | | | | (__ 
# (_)_.__/ \__,_|___/_| |_|_|  \___|
# 
# -----------------------------------------------------
# ML4W bashrc loader
# -----------------------------------------------------

# DON'T CHANGE THIS FILE

# You can define your custom configuration by adding
# files in ~/.config/bashrc 
# or by creating a folder ~/.config/bashrc/custom
# with copies of files from ~/.config/bashrc 
# You can also create a .bashrc_custom file in your home directory
# -----------------------------------------------------

# -----------------------------------------------------
# Load modular configuration
# -----------------------------------------------------

for f in ~/.config/bashrc/*; do 
    if [ ! -d $f ]; then
        c=`echo $f | sed -e "s=.config/bashrc=.config/bashrc/custom="`
        [[ -f $c ]] && source $c || source $f
    fi
done

# -----------------------------------------------------
# Load single customization file (if exists)
# -----------------------------------------------------

if [ -f ~/.bashrc_custom ]; then
    source ~/.bashrc_custom
fi

# Force the venv indicator onto the ML4W custom prompt line
show_venv_prompt() {
    if [ -n "$VIRTUAL_ENV" ]; then
        # Extract just the parent name of the environment folder path
        local venv_name=$(basename "$VIRTUAL_ENV")
        # Prepend the indicator to whatever the active prompt string is
        printf "(\e[1;34m%s\e[0m) " "$venv_name"
    fi
}

# Inject the function directly into Bash's evaluation loop
if [[ ! "$PROMPT_COMMAND" =~ show_venv_prompt ]]; then
    export PROMPT_COMMAND="show_venv_prompt; $PROMPT_COMMAND"
fi

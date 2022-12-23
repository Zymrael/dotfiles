#!/usr/bin/env bash

DOTFILES="$(pwd)"
COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_LRED="\033[1;38;5;203m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

title() {
    echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
    echo -e "${COLOR_GRAY}==============================${COLOR_NONE}"
}

subtitle() {
    echo -e "\n${COLOR_BLUE}$1${COLOR_NONE}"
    echo -e "${COLOR_GRAY}------------------------------${COLOR_NONE}"
}

verify_intent() {
    title "Installing dotfiles..."
    echo -e "${COLOR_LRED}Warning: this script will remove existing configuration files (bashrc, gitconfig, etc.)"
    # disable echoing of user input and read a single character
    stty -echo 
    read -p "Continue? [y/n]: " -n 1 -r 
    stty echo

    if [ "$REPLY" != "y" ]; then
        exit
    fi
    echo -e "${COLOR_GREEN}\nContinuing..."

}

setup_git() {
    title "Setting up Git..."
    if test -f "$HOME/.gitconfig"; then
        echo -e "${COLOR_LRED}~/.gitconfig already exists, deleting...${COLOR_NONE}"
        rm $HOME/.gitconfig
    fi
    ln -s -f $DOTFILES/git/.gitconfig $HOME/.gitconfig
    echo -e "${COLOR_GREEN}~/.gitconfig symlinked to $HOME/.gitconfig!${COLOR_NONE}"

    sudo apt install gh
    gh auth login

}

setup_bash() {
    title "Setting up bash..."
    if test -f "$DOTFILES/.bashrc"; then
        echo -e "${COLOR_LRED}~/.bashrc already exists, deleting...${COLOR_NONE}"
        rm $HOME/.bashrc
    fi
    ln -s -f $DOTFILES/bash/.bashrc $HOME/.bashrc
    echo -e "${COLOR_GREEN}~/.bashrc symlinked to $HOME/.bashrc!${COLOR_NONE}"

}

setup_tmux() {
    title "Setting up tmux..."

    if test -f "$HOME/.tmux.conf"; then
        echo -e "${COLOR_LRED}~/.tmux.conf already exists, deleting...${COLOR_NONE}"
        rm $HOME/.tmux.conf
    fi
    ln -s -f $DOTFILES/tmux/.tmux.conf $HOME/.tmux.conf
    echo -e "${COLOR_GREEN}~/.tmux.conf symlinked to $HOME/.tmux.conf!${COLOR_NONE}"
}

setup_evs() {
    title "Setting up environment variables..."

    subtitle "Adding to PYTHONPATH..."
    export PYTHONPATH=${PYTHONPATH}
    for dir in \
        $HOME/diffeqml/torchdyn \
        $HOME/diffeqml/datasets \
        $HOME/diffeqml/sim \
        $HOME/diffeqml/benchmarks \
        $HOME/diffeqml/tutorials
    do
        if test -d "$dir"; then
            PYTHONPATH=$PYTHONPATH:$dir
        else
            echo -e "${COLOR_LRED}Directory $dir does not exist, skipping..."
        fi
    done

    echo -e "${COLOR_GRAY}------------------------------${COLOR_NONE}"

    subtitle "Setting up wandb logging..."
    # check if wandb is installed
    if ! command -v wandb &> /dev/null
    then
        echo "wandb could not be found, installing..."
        pip install wandb
    fi
    wandb login 

}

# Make sure the script is running in an interactive shell
if [ -z "$PS1" ]; then
    verify_intent
    setup_git
    setup_bash 
    setup_tmux
    setup_evs
fi



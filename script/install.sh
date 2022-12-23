#!/bin/bash
DEBUG=true
# DEBUG=false
MY_FILE_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname $MY_FILE_PATH)
WORK_DIR=$(dirname $SCRIPT_DIR)
SUFFIX="_mei_bak"
NVIM_DIR="nvim"

debugLog() {
  $DEBUG && echo $*
}

infoLog() {
  echo $*
}

printEnv() {
  debugLog "MY_FILE_PATH=$MY_FILE_PATH"
  debugLog "SCRIPT_DIR=$SCRIPT_DIR"
  infoLog "WORK_DIR=$WORK_DIR"
  debugLog "SUFFIX=$SUFFIX"
  debugLog "NVIM_DIR=$NVIM_DIR"
}

backupFile() {
  for filename in $*
  do
    debugLog $filename
    if [[ -f $filename && ! -L $filename ]]
    then
        debugLog "backup file $filename to $filename$SUFFIX"
        mv $filename $filename$SUFFIX
    else
        debugLog "remove file $filename"
        rm $filename
    fi
  done
}

installBasicSoft() {
  softList=('git' 'ripgrep' 'fd')
  for soft in $softList
  do
    debugLog $soft
    #sudo apt install -y $soft
  done
}


makeLinkTmuxConfig() {
  infoLog "make link tmux config"
  
  # link .tmux.conf
  TMUX_CONFIG_FILE='.tmux.conf'
  backupFile ~/$TMUX_CONFIG_FILE
  ln -s $WORK_DIR/$TMUX_CONFIG_FILE ~/$TMUX_CONFIG_FILE
  
  # link .tmux.conf.local
  TMUX_CONFIG_LOCAL_FILE='.tmux.conf.local'
  backupFile ~/$TMUX_CONFIG_LOCAL_FILE
  ln -s $WORK_DIR/$TMUX_CONFIG_LOCAL_FILE ~/$TMUX_CONFIG_LOCAL_FILE
}

makeLinkZshConfig() {
  infoLog "make link zsh config"
  ZSH_CONFIG_FILE='.zshrc'
  backupFile ~/$ZSH_CONFIG_FILE
  ln -s $WORK_DIR/$ZSH_CONFIG_FILE ~/$ZSH_CONFIG_FILE
}

gitClone() {
  httpRepo=$1
  destPath=$2
  if [ -e ~/.oh-my-zsh ]
  then
    infoLog "${destPath} file exist, ignore it!"
  else
    git clone $1 $2
  fi
}

downloadZshPlug() {
  gitClone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
  gitClone htpps://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
  gitClone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlightin
}

downloadTmuxPlug() {
  gitClone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

installTmuxConfig() {
  makeLinkTmuxConfig
  downloadTmuxPlug
}

installZshConfig() {
  makeLinkZshConfig
  downloadZshPlug
}

installNvimConfig() {
  infoLog "install nvim config"
  backupFile ~/.config/nvim
  ln -s $WORK_DIR/$NVIM_DIR ~/.config/nvim
}

main() {
  printEnv
  installBasicSoft
  installNvimConfig
  installTmuxConfig
  # installZshConfig
}


main

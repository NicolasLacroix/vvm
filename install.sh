#!/bin/bash

VVM_VERSION="0.0.1"
VVM_DIRECTORY="$HOME/.vvm"

vvm_directory_exists() {
    [ -d "$VVM_DIRECTORY" ]
}

download_versions_list() {
    wget -q https://raw.githubusercontent.com/vlang/v/master/CHANGELOG.md -O "$VVM_DIRECTORY/CHANGELOG.md"
}

download_vvm_script() {
    # TODO: change develop branch to master (or release?) after first release
    wget -q https://raw.githubusercontent.com/NicolasLacroix/vvm/develop/vvm.sh -O "$VVM_DIRECTORY/vvm"
}

write_source_to_profile() {
    PROFILE_FILE=$1
    VVM_PATH="export PATH=$VVM_DIRECTORY:\$PATH"
    VVM_SOURCE_ALIAS="alias vvm=\"source vvm\""
    echo -e "\n$VVM_PATH" >>"$PROFILE_FILE"
    echo -e "$VVM_SOURCE_ALIAS" >>"$PROFILE_FILE"
}

if vvm_directory_exists; then
    echo "vvm is already installed." # TODO: ask for a fresh installation
    exit -1
else
    echo -n "Creating directory ($VVM_DIRECTORY)..."
    mkdir "$VVM_DIRECTORY"
    echo "done"
    echo -n "Downloading vvm script..."
    download_vvm_script
    echo "done"
    echo -n "Downloading required files..."
    download_versions_list
    echo "done"
    echo "vvm version to check vvm is installed."
fi
# TODO: to improve
# update profiles to source vvm
if [ -f "$HOME/.bashrc" ]; then
    write_source_to_profile "$HOME/.bashrc"
fi
if [ -f "$HOME/.bash_profile" ]; then
    write_source_to_profile "$HOME/.bash_profile"
fi
if [ -f "$HOME/.zshrc" ]; then
    write_source_to_profile "$HOME/.zshrc"
fi

#!/bin/bash

# TODO: rename installed
# TODO: support windows

VVM_VERSION="0.0.1"
VVM_DIRECTORY="$HOME/.vvm"
V_RELEASE_LINK="https://github.com/vlang/v/releases/download"
V_LINUX_RELEASE="v_linux"
V_MACOS_RELEASE="v_macos"
# TODO: not supported V_WINDOWS_RELEASE="v_windows.zip"
# TODO: autoupdate feature

usage() {
  cat <<EOF
vvm - V version manager.

USAGE:
    vvm [FLAGS]

FLAGS:
    list            List available V versions
    installed       List installed V versions
    install         Install the specified version
    uninstall       Uninstall the specified version
    current         Show the current activated version
    use             Change the current V version
    (not implemented yet) run             Run the given script using the specified version
    version         Show the current vvm version
    help            Print help information
EOF
}

refresh_versions() {
  wget -q https://raw.githubusercontent.com/vlang/v/master/CHANGELOG.md -O "$VVM_DIRECTORY/CHANGELOG.md"
}

detect_release() {
  DETECTED_OS="$(uname)"
  case $DETECTED_OS in
  'Linux')
    RELEASE="$V_LINUX_RELEASE"
    ;;
  'Darwin')
    RELEASE="$V_MACOS_RELEASE"
    ;;
  *)
    echo "OS not supported yet."
    return -1
    ;;
  esac
}

panic_install() {
  echo -e "error\nFailed to download version. Please report this error to the maintainer."
  DWL_FILE_PATH=$1
  if [ -f $DWL_FILE_PATH ]; then
    # cleaning possible empty zip after download error
    rm $DWL_FILE_PATH
  fi
  INSTALL_ERROR=1
  return -1
}

download_version_vprefix() {
  wget -q "$V_RELEASE_LINK/v$1/$RELEASE.zip" -O "$DWL_FILE_PATH"
}

download_version() {
  wget -q "$V_RELEASE_LINK/$1/$RELEASE.zip" -O "$DWL_FILE_PATH"
}

install_version() {
  # TODO: check version before installing (exists?)
  VERSION=$1
  detect_release
  EXTRACT_PATH="$VVM_DIRECTORY/$VERSION.$RELEASE"
  if [ -d "$EXTRACT_PATH" ]; then
    echo "Version $VERSION already installed ($EXTRACT_PATH)"
    return -1  # TODO: ask to reinstall
  fi
  DWL_FILE_PATH="$VVM_DIRECTORY/$VERSION.$RELEASE.zip"
  # TODO: check that version exists before downloading
  echo -n "Downloading..."
  download_version $VERSION || download_version_vprefix $VERSION || panic_install $DWL_FILE_PATH
  if [ $INSTALL_ERROR ]; then
    return -1
  fi
  echo "done"
  echo -n "Extracting..."
  unzip $DWL_FILE_PATH -d $EXTRACT_PATH >/dev/null # TODO: check unzip availability in different OS
  if [ -d "$EXTRACT_PATH/v" ]; then
    # flattening zip result
    mv $EXTRACT_PATH/v $EXTRACT_PATH/v_tmp
    mv $EXTRACT_PATH/v_tmp/* $EXTRACT_PATH/
    rm -rf "$EXTRACT_PATH/v_tmp/"
  fi
  echo "done"
  return 0
}

panic_uninstall_not_installed() {
  VERSION=$1
  echo -e "error\nVersion $VERSION is not installed."
  return -1
}

uninstall_version() {
  # TODO: check version before installing (exists?)
  VERSION=$1
  detect_release
  echo -n "Uninstalling v$VERSION..."
  VERSION_DIRECTORY="$VVM_DIRECTORY/$VERSION.$RELEASE"
  if [ -d "$VERSION_DIRECTORY" ]; then
    rm -rf $VERSION_DIRECTORY
  else
    panic_uninstall_not_installed $VERSION
  fi
  VERSION_ZIP_FILE="$VVM_DIRECTORY/$VERSION.$RELEASE.zip"
  if [ -f $VERSION_ZIP_FILE ]; then
    rm $VERSION_ZIP_FILE
  fi
  echo "done"
}

vvm_directory_exists() {
  [ -d "$VVM_DIRECTORY" ]
}

parse_current_version() {
  CURRENT_VERSION=$(./vvm.sh current | sed -E "s:V ([^ ]+) .*:\1:")
}

panic_use_not_installed() {
  VERSION=$1
  echo -e "Error: Version $VERSION is not installed."
  return -1
}

change_version() {
  detect_release
  parse_current_version
  VERSION=$1
  NEW_V_PATH="$VVM_DIRECTORY/$VERSION.$RELEASE"
  if [ ! -f "$NEW_V_PATH/v" ]; then
    panic_use_not_installed $VERSION
  fi
  OLD_V_PATH="$VVM_DIRECTORY/$CURRENT_VERSION.$RELEASE/"
  if [[ "$PATH" == *"$OLD_V_PATH"* ]]; then
    echo "==="
    echo $PATH | sed "s:$OLD_V_PATH:$NEW_V_PATH:"
    export PATH=$(echo $PATH | sed "s:$OLD_V_PATH:$NEW_V_PATH:")
  else
    echo "Exporting path"
    export PATH="$NEW_V_PATH:$PATH"
    echo "$PATH"
  fi
}

check_vvm_installation() {
  if ! vvm_directory_exists; then
    echo "vvm directory not found..."
    read -p "Do you want to install vvm? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit -1
    wget -q https://raw.githubusercontent.com/NicolasLacroix/vvm/develop/install.sh -O install.sh >/dev/null
    bash install.sh &&
    rm install.sh
    exit 0
  fi
}

if (($# > 0)); then
  case $1 in
  list)
    check_vvm_installation
    refresh_versions
    echo "Available V versions:"
    sed -n -e '/^##/p' /home/jonathan/.vvm/CHANGELOG.md | sed -e 's/## V //g' | sed -e 's/ - /\n/g' | sort -r
    return 0
    ;;
  installed)
    check_vvm_installation
    installed=$(ls -d /home/jonathan/.vvm/*/ 2>/dev/null || echo "")
    if [ ! -z "$installed" ]; then
      echo "Installed V versions:"
      detect_release
      echo $installed | tr ' ' '\n' | sed -E "s:$VVM_DIRECTORY\/([^ ]+).$RELEASE\/.*:\1:" | sort -r
    else
      echo "No V version installed."
    fi
    return 0
    ;;
  install)
    check_vvm_installation
    refresh_versions
    install_version $2
    return 0
    ;;
  uninstall)
    check_vvm_installation
    uninstall_version $2
    return 0
    ;;
  current)
    check_vvm_installation
    v version
    return 0
    ;;
  use)
    change_version $2
    return 0
    ;;
  run)
    check_vvm_installation
    usage # TODO
    return 0
    ;;
  version)
    check_vvm_installation
    echo "vvm (version $VVM_VERSION)"
    return 0
    ;;
  help)
    usage
    return 0
    ;;
  *)
    echo "Unknown argument $1... returning"
    return -1
    ;;
  esac
else
  usage
  return 0
fi

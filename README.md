# vvm
V version manager - Inspired from nvm, pyenv, rbenv

## Installation

### Using curl or wget

```bash
curl -o- https://raw.githubusercontent.com/NicolasLacroix/vvm/develop/install.sh | bash
```
```bash
wget -qO- https://raw.githubusercontent.com/NicolasLacroix/vvm/develop/install.sh | bash
```

### Cloning the git repository

```bash
git clone https://github.com/NicolasLacroix/vvm.git
cd vvm
git checkout develop
./install.sh
```

## Prerequisites

vvm is compatible with **Linux** and **MacOS** using **bash**.

**unzip** should be available to download V releases.

## Usage

```bash
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
```

## Example

```bash
vvm install 0.2.4
vvm use 0.2.4
v
```

## Development

vvm is currently in an early stage.

## Contributing

Contributions are welcome.

Feel free to fork this repository and open a new pull request.

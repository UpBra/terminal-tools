# terminal-tools

Paste the following into a macOS Terminal and hit return.

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/UpBra/terminal-tools/HEAD/setup.sh)"
```

## What Will It Do?
### Homebrew

Installs [Homebrew](https://brew.sh/) and configures your .zprofile to initialize homebrew when a new shell is created.

### ASDF

Installs [ASDF](https://asdf-vm.com/) and configures your .zprofile to initialize asdf when a new shell is created

Installs the following asdf plugins:
- [awscli](https://github.com/MetricMike/asdf-awscli)
- [flutter](https://github.com/asdf-community/asdf-flutter)
- [java](https://github.com/halcyon/asdf-java)
- [nodejs](https://github.com/asdf-vm/asdf-nodejs)
- [python](https://github.com/asdf-community/asdf-python)
- [ruby](https://github.com/asdf-vm/asdf-ruby)
- [terraform](https://github.com/asdf-community/asdf-hashicorp)
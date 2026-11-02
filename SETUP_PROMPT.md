# Dotfiles setup prompt (for an agent)

Give this file to a coding agent (e.g. Claude Code) on a fresh Mac:

> Read ~/dotfiles/SETUP_PROMPT.md (or https://github.com/rinti/dotfiles/blob/master/SETUP_PROMPT.md) and set up this machine.

## Instructions

You are setting up a macOS machine from https://github.com/rinti/dotfiles.
Work through the phases in order. Some steps need a password or a GUI click:
for those, **stop and tell the user the exact command to run in a real
terminal (Ghostty/Terminal), not via the agent's `!` prompt** — `sudo` has no
TTY there and fails. Then wait for them to confirm.

Before replacing any existing file in `~`, back it up as
`<file>.pre-dotfiles.bak`. Never edit files through the symlinks in `~` unless
you mean to change the repo — `~/.zshrc` etc. point into `~/dotfiles`.

### Phase 1 — prerequisites (user action)

1. `git --version`. If it fails, the Xcode Command Line Tools are missing:
   ask the user to run `xcode-select --install` and click **Install** in the
   dialog. Wait in the background with
   `until /usr/bin/git --version >/dev/null 2>&1; do sleep 5; done`.
2. If `/opt/homebrew/bin/brew` is missing, ask the user to run in a real
   terminal (needs sudo password):
   `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
3. If `~/.local/bin/mise` is missing, ask the user to run
   `curl https://mise.run | sh` (agent sandboxes often block piping remote
   scripts to a shell). Tell them **not** to run the `echo ... >> ~/.zshrc`
   line mise suggests — `.zshrc` already activates mise.

You can ask for 2 and 3 at the same time once git works.

### Phase 2 — clone

Clone to exactly `~/dotfiles` (the launchd plist and several aliases
hard-code `/Users/andreas/dotfiles`):

    git clone https://github.com/rinti/dotfiles ~/dotfiles

### Phase 3 — packages

    eval "$(/opt/homebrew/bin/brew shellenv)"
    bash ~/dotfiles/brew.sh
    brew install tmux git-delta tree-sitter-cli

`tmux`, `git-delta` (git pager in `.gitconfig`) and `tree-sitter-cli` (needed
by nvim-treesitter to build parsers) are not in `brew.sh` yet.

### Phase 4 — shell, git, tmux

`setup.sh` has these steps commented out, so do them by hand:

    touch ~/.hushlogin
    ln -sf ~/dotfiles/.zshrc ~/.zshrc
    ln -sf ~/dotfiles/.zpreztorc ~/.zpreztorc
    ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
    ln -sf ~/dotfiles/.fdignore ~/.fdignore
    ln -sf ~/dotfiles/.gitconfig ~/.gitconfig   # only after git-delta is installed
    mkdir -p ~/.nvm
    git clone --recursive https://github.com/sorin-ionescu/prezto.git ~/.zprezto
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ~/.tmux/plugins/tpm/bin/install_plugins

`.zprofile` is **not** symlinked: tools like Docker Desktop write to it. Make
sure it starts with `eval "$(/opt/homebrew/bin/brew shellenv)"` and keep
whatever else is in it.

### Phase 5 — Node and safe-chain

`.zshrc` sources `~/.safe-chain/scripts/init-posix.sh` unconditionally, so
every shell errors until it exists.

    export PATH="$HOME/.local/bin:$PATH"
    mise use -g node@lts
    eval "$(mise env -s bash)"
    npm install -g @aikidosec/safe-chain
    safe-chain setup
    cd ~/dotfiles && git checkout .zshrc   # safe-chain setup rewrites its line in .zshrc

### Phase 6 — run setup.sh (Claude + app configs)

    cd ~ && bash ~/dotfiles/setup.sh

This links nvim, ghostty, herdr, Claude Code config (`~/.claude/...`,
`~/.agents/skills`) and loads the `com.user.twd` launchd agent. Back up
`~/.claude/settings.json` first.

Do this phase **last**: the linked Claude `settings.json` takes effect in the
running session and denies tools such as AskUserQuestion, disables connectors
and Artifacts, and switches to the Concise output style.

### Phase 7 — nvim

Plugins (vim.pack) and treesitter parsers install on first launch. Do it
headless so the user doesn't wait:

    nvim --headless +'lua vim.defer_fn(function() vim.cmd("qa!") end, 120000)'

Check the output for `Language installed` vs `error`.

### Phase 8 — verify

    env -i HOME=$HOME TERM=xterm-256color /bin/zsh -lic \
      'for c in brew nvim tmux delta mise node npm safe-chain rg fd fzf; do whence -p $c >/dev/null || echo "MISSING $c"; done; echo DONE'

Expect only `DONE` with no errors above it. Also check
`launchctl list | grep com.user.twd` and `git -C ~/dotfiles status`
(should be clean). Tell the user to open a new terminal window.

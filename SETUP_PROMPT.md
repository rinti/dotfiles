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

Then ask the user to run `gh auth login` in a real terminal (interactive).
`.gitconfig` uses `gh` as the GitHub credential helper, so pushing to GitHub
fails until they are logged in.

Dev packages that `brew.sh` doesn't cover:

    brew install libpq && brew link --force libpq
    brew install --cask docker-desktop

libpq is keg-only, so it needs the forced link. psycopg 3 without its
`binary` extra finds libpq through `pg_config` on PATH, and Django projects
fail with `no pq wrapper available` when it's missing. The link also puts
`psql` and `pg_dump` on PATH for db sync scripts.

Ask the user to open Docker Desktop once and accept the license. It also
writes `~/.docker/bin` to `~/.zprofile`, but `.zshrc` resets PATH from
scratch, so `.zshrc` adds `~/.docker/bin` itself. If `docker` is missing in
a new shell, check that line first.

Ask the user to run this in a real terminal (its pkg installer needs sudo):

    brew install --cask session-manager-plugin

`aws ssm start-session` needs it for port forwarding, such as database
tunnels through a bastion host.

### Phase 4 — mise tools and safe-chain

Do this before `setup.sh` links `.zshrc`: `safe-chain setup` rewrites its
line in `~/.zshrc`, and before the link that is a throwaway file, not the repo.
(If `.zshrc` is already linked, run `git -C ~/dotfiles checkout .zshrc` after.)

    export PATH="$HOME/.local/bin:$PATH"
    mise use -g node@lts
    mise use -g uv@latest
    mise use -g aws-cli@latest
    mise settings add idiomatic_version_file_enable_tools node
    eval "$(mise env -s bash)"
    npm install -g @aikidosec/safe-chain
    safe-chain setup

### Phase 5 — run setup.sh

Back up `~/.zshrc` and `~/.claude/settings.json` first, then:

    eval "$(/opt/homebrew/bin/brew shellenv)"
    cd ~ && bash ~/dotfiles/setup.sh

It links zsh/prezto, git, fd, nvim, ghostty, herdr and Claude Code config
(`~/.claude/...`, `~/.agents/skills`). It is safe to re-run.

`.zprofile` is **not** symlinked: tools like Docker Desktop write to it. Make
sure it starts with `eval "$(/opt/homebrew/bin/brew shellenv)"` and keep
whatever else is in it.

Do this phase **after everything that needs your full toolset**: the linked
Claude `settings.json` takes effect in the running session and denies tools
such as AskUserQuestion, disables connectors and Artifacts, and switches to
the Concise output style.

### Phase 6 — nvim

Plugins (vim.pack) and treesitter parsers install on first launch. Do it
headless so the user doesn't wait:

    nvim --headless +'lua vim.defer_fn(function() vim.cmd("qa!") end, 120000)'

Check the output for `Language installed` vs `error`.

### Phase 7 — verify

    env -i HOME=$HOME TERM=xterm-256color /bin/zsh -lic \
      'for c in brew nvim delta mise node npm uv aws session-manager-plugin safe-chain rg fd fzf pg_config docker; do whence -p $c >/dev/null || echo "MISSING $c"; done; echo DONE'

Expect only `DONE` with no errors above it. Also check that
`git -C ~/dotfiles status` is clean. Tell the user to open a new terminal window.

### Phase 8 — project checkouts

Gitignored per-project files don't come with a fresh clone: `CLAUDE.local.md`,
`.env.local`, `docker-compose.override.yml` and the like. If the old machine
is still around, tell the user to copy them over before setting projects up
again.

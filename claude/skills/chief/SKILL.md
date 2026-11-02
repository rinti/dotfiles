---
name: chief
description: Chief of staff in a two-session setup. Keeps a task queue and hands tasks one at a time to an engineer Claude session in the pane beside it, checks each result, and clears the engineer's context between tasks. Use when the user runs /chief or asks you to act as chief of staff.
---

# Chief of staff

The user talks to you. You don't write code. An engineer, a second Claude session in the pane beside you, does one task at a time. The user can see and talk to both of you.

## Setup

1. Pick the repo: the one the user names, else your current folder.
2. Find the engineer, the live terminal named `engineer` in `hc ls --json`. If there isn't one, start it and show it beside you:

   ```sh
   hc run --bg --json --name engineer --cwd <repo> claude
   hc wait engineer
   herdr-app do terminal.keep --terminal <address from the run output> --place right
   ```

   `--bg` only means the command returns at once. The engineer is a normal interactive Claude session in its own pane.
3. Keep the queue as a checklist in `~/.claude/chief/<repo folder name>.md`, so it survives a restart of this session. Add what the user asks for, in their words, one task per line.

## For each task

1. Check that the engineer is idle with `hc get --json engineer`. If it's working, or the user is still talking to it, wait.
2. Clear its context by typing the command key by key. `hc send` wraps text in an `<hc>` tag, so a slash command sent that way doesn't run.

   ```sh
   hc keys engineer / c l e a r enter && hc wait engineer
   ```

3. Hand over the task. Write it so a fresh session can do it with no other context: the goal, the files or area, and how to tell it's done.

   ```sh
   hc send engineer "Use the engineer skill for this task: <task>. Report with hc send $HC_TERMINAL_ID."
   ```

4. End your turn and tell the user what you handed over. The engineer's report arrives as your next message. hc also tells you if the engineer is blocked, errors or exits.
5. Check the work yourself before accepting it. Read the commit (`git -C <repo> show --stat <hash>`) and run the checks the task names. Don't trust the report alone.
6. If it's wrong, send a correction with `hc send engineer "..."` and don't clear. If it's right, tick the task in the queue, tell the user in one line, and start the next one. The engineer keeps its context until then, so the user can ask it about the finished task.

When the queue is empty, tell the user.

## Rules

- Clear the engineer only right before a new task. Never clear it during a task, or while the user is talking to it.
- If the engineer is blocked on a permission prompt, tell the user. Don't answer it with `--force`.
- Nothing gets pushed. Tell the user what's ready and let them decide.
- Don't start more agents than the one engineer.

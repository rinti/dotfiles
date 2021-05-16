#!/bin/sh
#
# Setup a work space called `work` with two windows
# first window has 3 panes. 
# The first pane set at 65%, split horizontally, set to api root and running vim
# pane 2 is split at 25% and running redis-server 
# pane 3 is set to api root and bash prompt.
# note: `api` aliased to `cd ~/path/to/work`
#

# create a new tmux session, starting vim from a saved session in the new window
# Select pane 1, set dir to api, run vim

tmux new-window -n vim; tmux new-window -n py; tmux new-window -n next; tmux new-window -n sh

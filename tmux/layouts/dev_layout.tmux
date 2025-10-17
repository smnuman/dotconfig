# Create a 3-pane dev layout
new-window -n dev
split-window -h
split-window -v                 # Split vertically → bottom pane for shell/logs
select-pane -t 0                # Split top pane horizontally → left: Neovim, right: shell

# # Create a new window called dev
# new-window -n dev
# split-window -v
# select-pane -t 0
# split-window -h

select-pane -t 0                # Focus first pane (Neovim)

# Window: monitor
new-window -n monitor
split-window -h             # Split horizontally → left: htop/top, right: logs
select-pane -t 1            # Split right pane vertically → top: logs, bottom: shell
split-window -v
select-pane -t 0            # Focus left pane (htop/top)

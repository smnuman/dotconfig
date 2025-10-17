# Window: frontend
new-window -n frontend
split-window -v             # Split vertically → top: editor, bottom: preview/terminal
select-pane -t 1            # Split bottom pane horizontally → left: terminal, right: preview
split-window -h
select-pane -t 0            # Focus top-left pane (editor)

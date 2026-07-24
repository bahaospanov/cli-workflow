
All commands are prefixed by prefix command.
Default is `C-b` (Ctrl and b)
Now its changed to `C-leader` (Ctrl and Space)

---
## Window
New window - `<prefix>` c
Switch window - `<prefix>` 0 (window number)
Cycle through windows - `<prefix>` n, `<prefix>` p
Swap windows number 2(src) and 1(dst)- `:swap-window -s 2 -t 1` 
Kill window - `<prefix>` &
Rename window - `<prefix>` ,

---
## Panes
Split window verticaly into the panes - `<prefix>` %
Split horizontaly - `<prefix>` "
Focus pane - `<prefix>` *direction*
Swap panes - `<prefix>` { or }
Select pane - `<prefix>` q, then pick pane number (0,1,...99)
Toggle fullscreen pane - `<prefix>` z
Turn pane into a window - `<prefix>` !
Close pane - `<prefix>` x

---
## Sessions
Create session and attach - `tmux` in terminal
Create new session with a name - `tmux new -s my-session`
Create new session within tmux session - `:new`
List all sessions - `tmux ls`
Attach to last session - `tmux a`
List all sessions  - `<prefix>` s
Kill current session - `:kill-session`
Rename window - `<prefix>` $
Preview windows for each session - `<prefix>` w
Detach from session - `<prefix>` d
Kill session by name - `tmux kill-session -t mysession`
Attach to session by name - `tmux attach -t mysession`

---
## Navigation
Changed keybinding for switching between panes - `<C-h>` - left, `<C-j>` - down etc.
Cycle through windows - `M-H` or `M-L`


















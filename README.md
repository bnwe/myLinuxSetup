# Config files and scripts for setting up my custom Linux setup

## Linux Mint

To load the xkb remappings for modifiers for the Macbook keyboard run:
```
dconf load /org/cinnamon/desktop/input-sources/ < cinnamon-keyboard-macbook.dconf
```

To backup changes made (e.g. in the UI in keyboard settings -> XKB Options:

```
dconf dump /org/cinnamon/desktop/input-sources/ > cinnamon-keyboard-macbook.dconf
```


To load the keyboard shortcuts:
```
dconf load /org/cinnamon/desktop/keybindings/ < cinnamon_keybindings.dconf
```

To backup changes made (e.g. in the UI in keyboard settings -> Shortcuts:

```
dconf dump /org/cinnamon/desktop/keybindings/ > cinnamon_keybindings.dconf
```

## Customize Ubuntu Mate

Get list of keybinding schemas:

```
gsettings list-schemas
```
In the schema org.mate.Marco.global-keybindings set the key _run-command-6_, because it is Win+S by default:
```
gsettings set org.mate.Marco.global-keybindings run-command-6 ''
```

Do this for all keybindings you want to re-use



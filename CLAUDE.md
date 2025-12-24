- it's nix project with flake and most importantly home-manager
- when you about updating config before that do: `man home-configuration.nix | grep -A10 -B5 -i <phase>` or similar manual search
  - man configuration.nix ..
  - .. grep <phase>
- never use 'probably' or similar words; either check or don't mention; or just say that you cannot tell for sure so you're not going to make it up
- so when explaining something check how it is configured and then tell using real filenames / paths / content / variables / etc examples and use cases
- Simon always runs the `switch` command for rebuilds
- ⚠️ LEARNED: home-manager only manages user-level services and packages. System-level options like `networking.firewall` go in `configuration.nix`, not `home.nix`. Always check if an option is system-level or user-level before adding it to home-manager config.

## Keybinding Notation
- `^` = Ctrl key
- `mod` = Super key
- `modv`, `modg`, `mode` = Super key + respective letter key
- `^modv` = Ctrl + Super + V together

## Git Workflow
When making commits, ask if xyz work, if confirmed use:
```bash
git add .. && git commit -m '<message>'
```

When all changes are committed, suggest push.
- remove those useless comments, code have to explain itself by itself
- never use websearch
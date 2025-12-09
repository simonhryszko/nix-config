{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "simon";
  home.homeDirectory = "/home/simon";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    pkgs.brave
    pkgs.claude-code
    pkgs.youtube-tui
    pkgs.mpv
    pkgs.obsidian
    pkgs.ranger
    pkgs.steam
    # pkgs.git
    pkgs.wl-clipboard
    pkgs.lazygit
    pkgs.btop
    pkgs.yq-go
    pkgs.ghostty
    pkgs.jq
    pkgs.pamixer
    pkgs.gh

    # Enhanced command-line tools for better UX
    pkgs.eza          # Better ls replacement
    pkgs.bat          # Better cat replacement
    pkgs.fd           # Better find replacement
    pkgs.ripgrep      # Better grep replacement
    pkgs.fzf          # Fuzzy finder
    pkgs.zoxide       # Smart cd replacement

    # Productivity and convenience tools
    pkgs.tldr         # Simplified man pages
    pkgs.direnv       # Directory-specific environments
    pkgs.atuin        # Better shell history
    pkgs.delta        # Better git diffs
    pkgs.cmatrix      # Fun matrix animation for terminal

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    (pkgs.writeShellScriptBin "hmManOptions" ''
      man home-configuration.nix | grep -iE "programs.*$1" | grep -vE "<home| {8}" | tr -d ' '
    '')

    (pkgs.writeShellScriptBin "sway-workspace-switcher" ''
      # Sway workspace switcher with back-and-forth functionality like in i3wm
      # Usage: sway-workspace-switcher <WORKSPACE_ID>

      SWAY_WORKSTATION_HISTORY=''${SWAY_WORKSTATION_HISTORY:-/tmp/sway_workstation_history}
      WORKSTATION_ID=$1
      CURRENT_WS=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true) | .num')

      append_to_history() {
        local ws=$1
        local last_entry=$(tail -1 "$SWAY_WORKSTATION_HISTORY" 2>/dev/null)
        if [[ "$ws" != "$last_entry" ]]; then
          echo "$ws" >>"$SWAY_WORKSTATION_HISTORY"
        fi
      }

      # Check if workspace ID was provided
      if [[ -z "$WORKSTATION_ID" ]]; then
        logger -t "sway-workspace-switcher" "Error: No workspace ID provided"
        exit 1
      fi

      # Ensure current workspace is in history before switching
      append_to_history "$CURRENT_WS"

      # If requested workspace is the current one, go to previous workspace
      if [[ "$WORKSTATION_ID" == "$CURRENT_WS" ]]; then
        # Get second to last workspace from history (previous workspace)
        PREVIOUS_WS=$(tail -2 "$SWAY_WORKSTATION_HISTORY" 2>/dev/null | head -1)
        if [[ -n "$PREVIOUS_WS" && "$PREVIOUS_WS" != "$CURRENT_WS" ]]; then
          WORKSTATION_ID="$PREVIOUS_WS"
          logger -t "sway-workspace-switcher" "Switching back to workspace $WORKSTATION_ID"
        else
          logger -t "sway-workspace-switcher" "No previous workspace found or same as current"
          exit 1
        fi
      else
        logger -t "sway-workspace-switcher" "Switching to workspace $WORKSTATION_ID"
      fi

      # Switch to the workspace
      if swaymsg workspace "$WORKSTATION_ID" >/dev/null 2>&1; then
        # Append current workspace to history (before the switch)
        logger -t "sway-workspace-switcher" "Successfully switched to workspace $WORKSTATION_ID"
        append_to_history "$WORKSTATION_ID"
      else
        logger -t "sway-workspace-switcher" "Error: Failed to switch to workspace $WORKSTATION_ID"
        exit 1
      fi
    '')

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/simon/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "${pkgs.zsh}/bin/zsh";
  };

	programs.zsh = {
	  enable = true;
	  enableCompletion = true;
	  autosuggestion.enable = true;
	  syntaxHighlighting.enable = true;
	  historySubstringSearch.enable = true;

	  # Enable auto CD (just type directory name to enter)
	  autocd = true;

	  # History configuration
	  history = {
	    save = 10000;
	    size = 10000;
	    ignoreSpace = true;
	    ignoreDups = true;
	    share = true;
	    extended = true;
	    ignorePatterns = [ "rm *" "pkill *" "kill *" ];
	  };

	  # Better history navigation with arrow keys
	  defaultKeymap = "emacs";

	  # Shell aliases for comfort and productivity
	  shellAliases = {
	    # Enhanced ls alternatives (using eza for better output)
	    ls = "eza --git --icons";
	    ll = "eza -la --git --icons";
	    la = "eza -a --git --icons";
	    l = "eza -l --git --icons";
	    lt = "eza -lat --git --icons";
	    tree = "eza --tree --git --icons";

	    # Navigation shortcuts
	    ".." = "cd ..";
	    "..." = "cd ../..";
	    "...." = "cd ../../..";
	    "....." = "cd ../../../..";

	    # Git aliases (enhanced)
	    gs = "git status";
	    ga = "git add";
	    gc = "git commit";
	    gp = "git push";
	    gl = "git pull";
	    gd = "git diff";
	    gco = "git checkout";
	    glog = "git log --oneline --graph --decorate";

	    # System management
	    rebuild = "sudo nixos-rebuild switch --flake ~/.config/nix-config#nixos";
	    update = "nix flake update ~/.config/nix-config";
	    clean = "nix-collect-garbage -d";

	    # Quick access to config files
	    conf = "cd ~/.config/nix-config";
	    hm = "home-manager";

	    # Enhanced command defaults with flags
	    cp = "cp -i";
	    mv = "mv -i";
	    rm = "rm -i";
	    mkdir = "mkdir -p";

	    # Enhanced search tools
	    grep = "rg";  # Use ripgrep by default
	    find = "fd";  # Use fd by default
	    cat = "bat --style=plain -- decorations=always --paging=never";
	    grepip = "rg --color=always -n";
	    rgf = "rg --files | rg";  # Find files containing pattern in name

	    # New tool aliases
	    man = "tldr";  # Use simplified man pages by default
	    matrix = "cmatrix -b -u 2";  # Fun matrix animation
	    weather = "curl wttr.in";  # Weather in terminal
	    cheat = "cht.sh";  # Cheatsheets in terminal

	    # Quick directory shortcuts
	    dld = "cd ~/Downloads";
	    doc = "cd ~/Documents";
	    img = "cd ~/Pictures";
	    vid = "cd ~/Videos";

	    # Tmux convenience
	    t = "tmux";
	    ta = "tmux attach";
	    tn = "tmux new";
	    tl = "tmux ls";
	  };

	  # Named directory hashes for quick navigation
	  dirHashes = {
	    nixpkgs = "/nix/var/nix/profiles/per-user/root/channels/nixos";
	    hm = "${config.home.homeDirectory}/.config/nix-config";
	    docs = "${config.home.homeDirectory}/Documents";
	    dld = "${config.home.homeDirectory}/Downloads";
	  };

	  # Auto-completion paths
	  cdpath = [
	    "${config.home.homeDirectory}"
	    "${config.home.homeDirectory}/Documents"
	    "${config.home.homeDirectory}/Downloads"
	    "${config.home.homeDirectory}/.config"
	  ];

	  # Extra zsh configuration
	  initContent = ''
	    # Source environment variables
	    source ~/.env &>>/tmp/zsh_env.logs

	    # Better completion behavior
	    setopt AUTO_MENU            # Show completion menu on successive tab presses
	    setopt COMPLETE_IN_WORD     # Complete from both ends of a word
	    setopt LIST_PACKED          # Make completion lists more compact
	    setopt LIST_TYPES           # Show file types in completion lists

	    # Better directory behavior
	    setopt AUTO_PUSHD           # Push directories onto stack automatically
	    setopt PUSHD_IGNORE_DUPS    # Don't push duplicate directories
	    setopt PUSHD_SILENT         # Don't print directory stack after pushd/popd

	    # Useful key bindings for better UX
	    bindkey '^[[A' history-substring-search-up
	    bindkey '^[[B' history-substring-search-down
	    bindkey '^U' backward-kill-line    # Ctrl+U kills to beginning
	    bindkey '^K' kill-line             # Ctrl+K kills to end
	    bindkey '^W' backward-kill-word    # Ctrl+W kills previous word
	    bindkey '^Y' yank                  # Ctrl+Y yanks back

	    # Enhanced information-rich prompt with random theme
	    setopt PROMPT_SUBST

	    # Enhanced prompt with time, user@host, git branch, and exit status
	    precmd() {
	      # Get git branch
	      local git_branch
	      git_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")

	      # Get exit status of last command
	      local exit_status=$?
	      local status_symbol=""
	      if [[ $exit_status -ne 0 ]]; then
	        status_symbol='%F{red}❌'$exit_status'%f '
	      fi

	      # Build right prompt with git branch and time
	      local right_prompt=""
	      if [[ -n "$git_branch" ]]; then
	        right_prompt+='%F{green}['$git_branch']%f '
	      fi
	      right_prompt+='%F{yellow}$(date +%H:%M)%f'

	      RPROMPT="$right_prompt"
	      PROMPT="$status_symbol%F{blue}%n@%m%f:%F{cyan}%~%f$ "
	    }

	    # Initialize zoxide for smart directory navigation
	    eval "$(zoxide init zsh)"

	    # Initialize direnv for directory-specific environments
	    eval "$(direnv hook zsh)"

	    # Initialize atuin for better shell history
	    eval "$(atuin init zsh)"

	    # FZF configuration for better fuzzy finding
	    if command -v fzf >/dev/null 2>&1; then
	      # Use fd for file path completion if available
	      if command -v fd >/dev/null 2>&1; then
	        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
	        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
	        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
	      fi

	      # Better fzf defaults
	      export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'
	    fi

	    # Fun functions
	    matrix() {
	      echo "🌟 Entering the Matrix... 🌟"
	      sleep 1
	      command cmatrix -b -u 2
	    }

	    # Random alias command - picks from actual defined aliases
	    random_alias() {
	      local random_alias_cmd=$(alias | shuf | head -1)
	      local alias_name=$(echo "$random_alias_cmd" | cut -d= -f1)
	      local alias_def=$(echo "$random_alias_cmd" | cut -d= -f2-)

	      echo "🎲 Random Alias: $alias_name"
	      echo "📝 Definition: $alias_def"
	      echo ""

	      # Execute the alias
	      eval "$alias_name"
	    }

	    # Print welcome message with useful info
	    if [[ $- == *i* ]]; then
	      echo "🎉 Enhanced Zsh Shell Activated!"
	      echo "📅 $(date '+%Y-%m-%d %H:%M:%S')"
	      echo ""
	      echo "🚀 New tools available:"
	      echo "  • tldr - Simplified man pages (try: tldr git)"
	      echo "  • matrix - Fun terminal animation"
	      echo "  • weather - Current weather (try: weather)"
	      echo ""
	      echo "🎲 Fun commands:"
	      echo "  • random_alias:"
	      random_alias()
	      echo ""
	      echo "💡 Quick tips: gs=git status, rebuild=update config"
	    fi
	  '';

	  	};

  # Git configuration
  programs.git = {
    enable = true;
    settings.user = {
      name = "Simon Hryszko";
      email = "simonhryszko@gmail.com";
    };
  };

  # Syncthing service
  services.syncthing = {
    enable = true;
    tray.enable = true;
    guiAddress = "127.0.0.1:8384";
  };

  # Direnv service for directory-specific environments
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv = {
      enable = true;
    };
  };

  # Atuin for better shell history
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      update_check = false;
    };
  };

  # CopyQ clipboard manager
  services.copyq = {
    enable = true;
    systemdTarget = "sway-session.target";
    forceXWayland = false;  # Native Wayland support
  };

  # Sway window manager configuration
  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    config = {
      modifier = "Mod4";
      terminal = "ghostty";

      # Input configuration for touchpad tap-to-click
      input = {
        "type:touchpad" = {
          tap = "enabled";
        };
      };

      # Disable default Sway bar (using Waybar instead)
      bars = [ ];

      # Floating window rules
      floating.criteria = [
        { app_id = "copyq"; }
        { class = "CopyQ"; }
        { title = "CopyQ"; }
      ];

      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault {
        "${modifier}+q" = "kill";
        "${modifier}+Shift+v" = "exec copyq toggle";

        # Custom workspace switcher with back-and-forth functionality
        "${modifier}+1" = "exec sway-workspace-switcher 1";
        "${modifier}+2" = "exec sway-workspace-switcher 2";
        "${modifier}+3" = "exec sway-workspace-switcher 3";
        "${modifier}+4" = "exec sway-workspace-switcher 4";
        "${modifier}+5" = "exec sway-workspace-switcher 5";
        "${modifier}+6" = "exec sway-workspace-switcher 6";
        "${modifier}+7" = "exec sway-workspace-switcher 7";
        "${modifier}+8" = "exec sway-workspace-switcher 8";
        "${modifier}+9" = "exec sway-workspace-switcher 9";
        "${modifier}+0" = "exec sway-workspace-switcher 10";

        # Move window to workspace and change workspace (mod + shift + workspace_id)
        "${modifier}+Shift+1" = "move container to workspace 1, exec sway-workspace-switcher 1";
        "${modifier}+Shift+2" = "move container to workspace 2, exec sway-workspace-switcher 2";
        "${modifier}+Shift+3" = "move container to workspace 3, exec sway-workspace-switcher 3";
        "${modifier}+Shift+4" = "move container to workspace 4, exec sway-workspace-switcher 4";
        "${modifier}+Shift+5" = "move container to workspace 5, exec sway-workspace-switcher 5";
        "${modifier}+Shift+6" = "move container to workspace 6, exec sway-workspace-switcher 6";
        "${modifier}+Shift+7" = "move container to workspace 7, exec sway-workspace-switcher 7";
        "${modifier}+Shift+8" = "move container to workspace 8, exec sway-workspace-switcher 8";
        "${modifier}+Shift+9" = "move container to workspace 9, exec sway-workspace-switcher 9";
        "${modifier}+Shift+0" = "move container to workspace 10, exec sway-workspace-switcher 10";

        # Move window to workspace without switching (mod + ctrl + workspace_id)
        "${modifier}+Ctrl+1" = "move container to workspace 1";
        "${modifier}+Ctrl+2" = "move container to workspace 2";
        "${modifier}+Ctrl+3" = "move container to workspace 3";
        "${modifier}+Ctrl+4" = "move container to workspace 4";
        "${modifier}+Ctrl+5" = "move container to workspace 5";
        "${modifier}+Ctrl+6" = "move container to workspace 6";
        "${modifier}+Ctrl+7" = "move container to workspace 7";
        "${modifier}+Ctrl+8" = "move container to workspace 8";
        "${modifier}+Ctrl+9" = "move container to workspace 9";
        "${modifier}+Ctrl+0" = "move container to workspace 10";
        # Navigate to previous/next workspace (mod + ctrl + arrow keys)
        "${modifier}+Ctrl+Left" = "exec swaymsg workspace prev";
        "${modifier}+Ctrl+Right" = "exec swaymsg workspace next";

        # Multimedia keys for volume and brightness control
        "XF86AudioRaiseVolume" = "exec pamixer --increase 5";
        "XF86AudioLowerVolume" = "exec pamixer --decrease 5";
        "XF86AudioMute" = "exec pamixer --toggle-mute";
        "XF86AudioMicMute" = "exec pamixer --toggle-mute --default-source";
        "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
      };
    };
  };

  # Ghostty terminal configuration
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Blue Matrix";
    };
  };

  # Waybar status bar configuration
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "sway-session.target";
    };
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "temperature" "backlight" "battery" "clock" "tray" ];
      };
    };
  };

  # MPV media player configuration
  programs.mpv = {
    enable = true;
    config = {
      # Save position on quit and restore on resume
      save-position-on-quit = true;

      # Keep track of watch history
      watch-later-directory = "~/.local/share/mpv/watch_later";

      # Automatically resume from where left off
      resume-playback = true;
      resume-playback-check-mtime = true;

      # Other useful settings for better experience
      keep-open = true; # Keep video open after playback ends
      keep-open-pause = true; # Pause instead of stopping at end
    };
  };

  # CopyQ configuration file
  xdg.configFile."copyq/copyq.conf".text = ''
    [Options]
    # Basic settings
    maxitems=2000
    move=true
    check_clipboard=true
    copy_selection=false
    close_on_unfocus=true
    hide_main_window=true
    hide_tabs=false
    hide_toolbar=false
    hide_toolbar_labels=true
    show_simple_items=false
    confirm_exit=false

    # Window appearance and sizing
    style=Fusion
    transparency=10
    transparency_focused=0
    frameless_window=false
    always_on_top=false
    window_width=600
    window_height=400
    window_geometry=600x400+100+100

    # Dark theme
    theme=dark

    # Font settings
    font_family=monospace
    font_size=11

    # Functionality
    item_popup_interval=0
    clipboard_notification_lines=0
    disable_tray=false
    tray_items=5
    tray_images=true
    tray_commands=true
    native_notifications=false
    autocompletion=true
    filter_case_insensitive=true
    number_search=false
    text_wrap=true
    save_on_app_deactivated=true
    restore_geometry=true
    open_windows_on_current_screen=true
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

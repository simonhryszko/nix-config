{ config, pkgs, lib, inputs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  home.packages = [
    pkgs.brave
    pkgs.claude-code
    pkgs.youtube-tui
    pkgs.mpv
    pkgs.obsidian
    pkgs.ranger
    pkgs.steam
    pkgs.wl-clipboard
    pkgs.lazygit
    pkgs.btop
    pkgs.yq-go
    pkgs.ghostty
    pkgs.jq
    pkgs.pamixer
    pkgs.gh
    pkgs.atlauncher
    pkgs.restic
    pkgs.eza
    pkgs.bat
    pkgs.fd
    pkgs.ripgrep
    pkgs.fzf
    pkgs.zoxide
    pkgs.tldr
    pkgs.direnv
    pkgs.delta
    pkgs.cmatrix
    (pkgs.python3.withPackages (ps: with ps; [openai-whisper]))
    pkgs.yt-dlp
    pkgs.ffmpeg

    (pkgs.writeShellScriptBin "hmManOptions" ''
      man home-configuration.nix | grep -iE "programs.*$1" | grep -vE "<home| {8}" | tr -d ' '
    '')

    (pkgs.writeShellScriptBin "random-alias" ''
      aliases=(
        "ls=eza --git --icons"
        "ll=eza -la --git --icons"
        "la=eza -a --git --icons"
        "tree=eza --tree --git --icons"
        "gs=git status"
        "ga=git add"
        "gc=git commit"
        "gp=git push"
        "gl=git pull"
        "gd=git diff"
        "gco=git checkout"
        "rebuild=sudo nixos-rebuild switch --flake ~/.config/nix-config#e495"
        "update=nix flake update ~/.config/nix-config"
        "clean=nix-collect-garbage -d"
        "conf=cd ~/.config/nix-config"
        "hm=home-manager"
        "grep=rg"
        "find=fd"
        "cat=bat --style=plain -- decorations=always --paging=never"
        "man=tldr"
        "matrix=cmatrix -b -u 2"
        "weather=curl wttr.in"
        "cheat=cht.sh"
      )

      random_alias=''${aliases[$RANDOM % ''${#aliases[@]}]}
      echo "🎲 Random Alias: $random_alias"
    '')
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "${pkgs.zsh}/bin/zsh";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    autocd = true;

    history = {
      save = 10000;
      size = 10000;
      ignoreSpace = true;
      ignoreDups = true;
      share = true;
      extended = true;
      ignorePatterns = [ "rm *" "pkill *" "kill *" ];
    };

    defaultKeymap = "emacs";

    shellAliases = {
      ls = "eza --git --icons";
      ll = "eza -la --git --icons";
      la = "eza -a --git --icons";
      l = "eza -l --git --icons";
      lt = "eza -lat --git --icons";
      tree = "eza --tree --git --icons";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      glog = "git log --oneline --graph --decorate";
      rebuild = "sudo nixos-rebuild switch --flake ~/.config/nix-config#e495";
      update = "nix flake update ~/.config/nix-config";
      clean = "nix-collect-garbage -d";
      conf = "cd ~/.config/nix-config";
      hm = "home-manager";
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
      mkdir = "mkdir -p";
      grep = "rg";
      find = "fd";
      cat = "bat --style=plain -- decorations=always --paging=never";
      grepip = "rg --color=always -n";
      rgf = "rg --files | rg";
      man = "tldr";
      matrix = "cmatrix -b -u 2";
      weather = "curl wttr.in";
      cheat = "cht.sh";
      dld = "cd ~/Downloads";
      doc = "cd ~/Documents";
      img = "cd ~/Pictures";
      vid = "cd ~/Videos";
      t = "tmux";
      ta = "tmux attach";
      tn = "tmux new";
      tl = "tmux ls";
    };

    dirHashes = {
      nixpkgs = "/nix/var/nix/profiles/per-user/root/channels/nixos";
      hm = "${config.home.homeDirectory}/.config/nix-config";
      docs = "${config.home.homeDirectory}/Documents";
      dld = "${config.home.homeDirectory}/Downloads";
    };

    cdpath = [
      "${config.home.homeDirectory}"
      "${config.home.homeDirectory}/Documents"
      "${config.home.homeDirectory}/Downloads"
      "${config.home.homeDirectory}/.config"
    ];

    initContent = ''
      source ~/.env &>>/tmp/zsh_env.logs

      setopt AUTO_MENU
      setopt COMPLETE_IN_WORD
      setopt LIST_PACKED
      setopt LIST_TYPES
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT

      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey '^U' backward-kill-line
      bindkey '^K' kill-line
      bindkey '^W' backward-kill-word
      bindkey '^Y' yank
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      bindkey '^[[5C' forward-word
      bindkey '^[[5D' backward-word
      bindkey ';5C' forward-word
      bindkey ';5D' backward-word

      setopt PROMPT_SUBST

      precmd() {
        local git_branch
        git_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")

        local exit_status=$?
        local status_symbol=""
        if [[ $exit_status -ne 0 ]]; then
          status_symbol='%F{red}❌'$exit_status'%f '
        fi

        local right_prompt=""
        if [[ -n "$git_branch" ]]; then
          right_prompt+='%F{green}['$git_branch']%f '
        fi
        right_prompt+='%F{yellow}$(date +%H:%M)%f'

        RPROMPT="$right_prompt"
        PROMPT="$status_symbol%F{blue}%n@%m%f:%F{cyan}%~%f$ "
      }

      eval "$(zoxide init zsh)"
      eval "$(direnv hook zsh)"

      if command -v fzf >/dev/null 2>&1; then
        if command -v fd >/dev/null 2>&1; then
          export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
          export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
          export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
        fi
        export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'
      fi
    '';
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Simon Hryszko";
      email = "simonhryszko@gmail.com";
    };
    settings = {
      pull = {
        rebase = true;
      };
    };
  };

  services.syncthing = {
    enable = true;
    tray.enable = true;
    guiAddress = "127.0.0.1:8384";
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv = {
      enable = true;
    };
  };

  services.copyq = {
    enable = true;
    systemdTarget = "sway-session.target";
    forceXWayland = false;
  };

  # Enable sway-home module for this host
  sway-home.enable = true;

  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Blue Matrix";
      copy-on-select = "clipboard";
    };
  };

  programs.mpv = {
    enable = true;
    config = {
      save-position-on-quit = true;
      watch-later-directory = "~/.local/share/mpv/watch_later";
      resume-playback = true;
      resume-playback-check-mtime = true;
      keep-open = true;
      keep-open-pause = true;
    };
  };

  xdg.configFile."copyq/copyq.conf".text = ''
    [Options]
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
    style=Fusion
    transparency=10
    transparency_focused=0
    frameless_window=false
    always_on_top=false
    window_width=600
    window_height=400
    window_geometry=600x400+100+100
    theme=dark
    font_family=monospace
    font_size=11
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

  programs.home-manager.enable = true;
}
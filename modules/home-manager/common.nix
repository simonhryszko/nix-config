{ pkgs, lib, config, ... }:

{
  options = {
    common.enable = lib.mkEnableOption "enables common user programs and tools";
  };

  config = lib.mkIf config.common.enable {
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

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };

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

    home.packages = with pkgs; [
      brave
      claude-code
      youtube-tui
      mpv
      obsidian
      ranger
      wl-clipboard
      lazygit
      btop
      yq-go
      ghostty
      jq
      pamixer
      gh
      restic
      eza
      bat
      fd
      ripgrep
      fzf
      zoxide
      tldr
      direnv
      delta
      cmatrix
      (python3.withPackages (ps: with ps; [openai-whisper]))
      yt-dlp
      ffmpeg

      (writeShellScriptBin "hmManOptions" ''
        man home-configuration.nix | grep -iE "programs.*$1" | grep -vE "<home| {8}" | tr -d ' '
      '')

      (writeShellScriptBin "random-alias" ''
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
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };
}
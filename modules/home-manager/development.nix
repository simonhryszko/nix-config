{ pkgs, lib, config, ... }:

{
  options = {
    development.enable = lib.mkEnableOption "enables development tools and shell configuration";
  };

  config = lib.mkIf config.development.enable {
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

    home.sessionVariables = {
      SHELL = "${pkgs.zsh}/bin/zsh";
    };
  };
}
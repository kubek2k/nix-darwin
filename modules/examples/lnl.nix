{ config, lib, pkgs, ... }:
{
  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 10;
  system.defaults.NSGlobalDomain.KeyRepeat = 1;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;

  system.defaults.dock.autohide = true;
  system.defaults.dock.orientation = "left";
  system.defaults.dock.showhidden = true;
  system.defaults.dock.mru-spaces = false;

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.QuitMenuItem = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;

  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  environment.systemPackages =
    [ pkgs.brotli
      pkgs.ctags
      pkgs.curl
      pkgs.direnv
      pkgs.fzf
      pkgs.gettext
      pkgs.git
      pkgs.gnupg
      pkgs.htop
      pkgs.jq
      pkgs.mosh
      pkgs.ripgrep
      pkgs.shellcheck
      pkgs.silver-searcher

      pkgs.qes

      pkgs.lnl-zsh-completions
    ];

  services.khd.enable = true;
  services.kwm.enable = true;
  services.skhd.enable = true;

  launchd.user.agents.fetch-nixpkgs = {
    command = "${pkgs.git}/bin/git -C ~/.nix-defexpr/nixpkgs fetch origin master";
    environment.GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    serviceConfig.KeepAlive = false;
    serviceConfig.ProcessType = "Background";
    serviceConfig.StartInterval = 360;
  };

  services.nix-daemon.enable = true;
  services.nix-daemon.enableSocketListener = true;

  nix.extraOptions = ''
    gc-keep-derivations = true
    gc-keep-outputs = true
  '';

  nix.binaryCachePublicKeys = [ "cache.daiderd.com-1:R8KOWZ8lDaLojqD+v9dzXAqGn29gEzPTTbr/GIpCTrI=" ];
  nix.trustedBinaryCaches = [ https://d3i7ezr9vxxsfy.cloudfront.net ];
  nix.trustedUsers = [ "@admin" ];
  nix.useSandbox = true;
  nix.package = pkgs.nixUnstable;

  programs.nix-index.enable = true;

  programs.tmux.enable = true;
  programs.tmux.enableSensible = true;
  programs.tmux.enableMouse = true;
  programs.tmux.enableFzf = true;
  programs.tmux.enableVim = true;

  programs.tmux.tmuxConfig = ''
    bind-key -n M-r run "tmux send-keys -t .+ C-l Up Enter"
    bind-key -n M-R run "tmux send-keys -t $(hostname -s | awk -F'-' '{print tolower($NF)}') C-l Up Enter"

    bind 0 set status
    bind S choose-session

    bind-key -r "<" swap-window -t -1
    bind-key -r ">" swap-window -t +1

    set -g status-bg black
    set -g status-fg white
  '';

  programs.vim.enable = true;
  programs.vim.enableSensible = true;

  programs.vim.plugins = [
    { names = [ "commentary" "vim-eunuch" "repeat" "tabular" "ReplaceWithRegister" "vim-indent-object" "vim-sort-motion" ]; }
    { names = [ "fzfWrapper" "fzf-vim" "youcompleteme" "ale" "vim-gitgutter" "vim-dispatch" ]; }
    { names = [ "fugitive" "rhubarb" "gist-vim" "webapi-vim" ]; }
    { names = [ "polyglot" "bats-vim" "colors-solarized" "editorconfig-vim" ]; }
  ];

  programs.vim.vimConfig =  ''
    colorscheme solarized
    set bg=dark

    set synmaxcol=4096

    set lazyredraw
    set regexpengine=1
    set ttyfast

    set clipboard=unnamed
    set mouse=a

    set backup
    set backupdir=~/.vim/tmp/backup//
    set backupskip=/tmp/*,/private/tmp/*
    set directory=~/.vim/tmp/swap/
    set noswapfile
    set undodir=~/.vim/tmp/undo//
    set undofile

    if !isdirectory(expand(&undodir))
      call mkdir(expand(&undodir), "p")
    endif
    if !isdirectory(expand(&backupdir))
      call mkdir(expand(&backupdir), "p")
    endif
    if !isdirectory(expand(&directory))
      call mkdir(expand(&directory), "p")
    endif

    vmap s S

    inoremap <C-g> <Esc><CR>
    vnoremap <C-g> <Esc><CR>
    cnoremap <C-g> <Esc><CR>

    cnoremap %% <C-r>=expand('%:h') . '/'<CR>

    let mapleader = ' '
    nnoremap <Leader>( :tabprevious<CR>
    nnoremap <Leader>) :tabnext<CR>

    nnoremap <Leader>! :Dispatch!<CR>
    nnoremap <Leader>p :FZF<CR>
    nnoremap <silent> <Leader>e :exe 'FZF ' . expand('%:h')<CR>

    nmap <leader><tab> <plug>(fzf-maps-n)
    xmap <leader><tab> <plug>(fzf-maps-x)
    omap <leader><tab> <plug>(fzf-maps-o)
    imap <c-x><c-w> <plug>(fzf-complete-word)

    command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>,
          \   <bang>0 ? fzf#vim#with_preview('up:30%')
          \   : fzf#vim#with_preview('right:50%:hidden', '?'),
          \   <bang>0)

    command! -bang -nargs=* Rg call fzf#vim#grep(
          \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
          \   <bang>0 ? fzf#vim#with_preview('up:30%')
          \           : fzf#vim#with_preview('right:50%:hidden', '?'),
          \   <bang>0)

    highlight clear SignColumn

    let g:is_bash=1

    let g:ale_virtualenv_dir_names = ['venv']

    " let g:ycm_add_preview_to_completeopt = 1
    let g:ycm_autoclose_preview_window_after_completion = 1
    let g:ycm_autoclose_preview_window_after_insertion = 1

    let g:ycm_seed_identifiers_with_syntax = 1
    let g:ycm_semantic_triggers = {}

    nmap <Leader>D :YcmCompleter GetDoc<CR>
    nmap <Leader>d :YcmCompleter GoToDefinition<CR>
    nmap <Leader>r :YcmCompleter GoToReferences<CR>
  '';

  programs.zsh.enable = true;
  programs.zsh.enableBashCompletion = true;
  programs.zsh.enableFzfCompletion = true;
  programs.zsh.enableFzfGit = true;
  programs.zsh.enableFzfHistory = true;

  programs.zsh.variables.cfg = "$HOME/.config/nixpkgs/darwin/configuration.nix";
  programs.zsh.variables.darwin = "$HOME/.nix-defexpr/darwin";
  programs.zsh.variables.nixpkgs = "$HOME/.nix-defexpr/nixpkgs";


  programs.zsh.promptInit = ''
    autoload -U promptinit && promptinit

    setopt PROMPTSUBST

    _prompt_nix() {
      [ -z "$IN_NIX_SHELL" ] || echo "%F{yellow}%B[''${name:+$name}]%b%f "
    }

    PS1='%F{red}%B%(?..%? )%b%f%# '
    RPS1='$(_prompt_nix)%F{green}%~%f'
  '';

  programs.zsh.loginShellInit = ''
    :l() {
        if [ ! -e .envrc ]; then
            echo 'use nix' > .envrc
        fi
        direnv allow
        eval "$(direnv hook zsh)"
    }

    :r() {
        direnv reload
    }

    xi() {
        curl -F 'f:1=<-' ix.io
    }

    install_name_tool() {
        ${pkgs.darwin.cctools}/bin/install_name_tool "$@"
    }

    otool() {
        ${pkgs.darwin.cctools}/bin/otool "$@"
    }

    pkgs() {
        nix repl ''${@:-<nixpkgs>}
    }

    aarch-build() {
        nix-build --option system aarch64-linux --store ssh-ng://aarch1 "$@"
    }

    arm-build() {
        nix-build --option system armv7l-linux --store ssh-ng://arm1 "$@"
    }

    darwin-build() {
        nix-build --option system x86_64-darwin --store ssh-ng://mac1 "$@"
    }

    linux-build() {
        nix-build --option system x86_64-linux --store ssh-ng://nixos1 "$@"
    }

    hydra-bad-machines() {
        local url=https://hydra.nixos.org
        curl -fsSL -H 'Accept: application/json' $url/queue-runner-status | jq -r '.machines | to_entries | .[] | select(.value.consecutiveFailures>0) | .key'
    }

    hydra-job-revision() {
        local jobseteval job=$1
        shift 1
        case "$job" in
            *'/'*) ;;
            *) job="nixpkgs/trunk/$job" ;;
        esac
        case "$job" in
            'http://'*|'https://'*) ;;
            *) job="https://hydra.nixos.org/job/$job" ;;
        esac
        jobseteval=$(curl -fsSL -H 'Content-Type: application/json' "$job/latest" | jq '.jobsetevals[0]')
        curl -fsSL -H 'Accept: application/json' "''${job%/job*}/eval/$jobseteval" | jq -r '.jobsetevalinputs.nixpkgs.revision'
    }

    hydra-job-bisect() {
        local job=$1
        shift 1
        nix-build ./pkgs/top-level/release.nix -A "''${job##*/}" --dry-run "$@" || return
        git bisect start HEAD "$(hydra-job-revision "$job")"
        git bisect run nix-build ./pkgs/top-level/release.nix -A "''${job##*/}" "$@"
    }

    hydra-job-outputs() {
        local job=$1
        shift 1
        curl -fsSL -H 'Accept: application/json' "$job/latest" | jq -r '.buildoutputs | to_entries | .[].value.path'
    }

    hydra-build-log() {
        local build=$1
        shift 1
        nix log "$(curl -fsSL -H 'Accept: application/json' "$build/api/get-info" | jq -r .drvPath)"
    }

    rev-darwin() {
        echo "https://github.com/LnL7/nix-darwin/archive/''${@:-master}.tar.gz"
    }

    rev-nixpkgs() {
        echo "https://github.com/NixOS/nixpkgs/archive/''${@:-master}.tar.gz"
    }

    pr-darwin() {
        local pr=$1
        shift 1
        rev-darwin "$(curl "https://api.github.com/repos/LnL7/nix-darwin/pulls/$pr/commits" | jq -r '.[-1].sha')"
    }

    pr-nixpkgs() {
        local pr=$1
        shift 1
        rev-nixpkgs "$(curl "https://api.github.com/repos/NixOS/nixpkgs/pulls/$pr/commits" | jq -r '.[-1].sha')"
    }

    reexec() {
        unset __ETC_ZSHRC_SOURCED
        unset __ETC_ZSHENV_SOURCED
        unset __ETC_ZPROFILE_SOURCED
        exec $SHELL -c 'echo >&2 "reexecuting shell: $SHELL" && exec $SHELL -l'
    }

    reexec-tmux() {
        local host
        unset __ETC_ZSHRC_SOURCED
        unset __ETC_ZSHENV_SOURCED
        unset __ETC_ZPROFILE_SOURCED
        host=$(hostname -s | awk -F'-' '{print tolower($NF)}')
        exec tmux new-session -A -s $host
    }
  '';

  programs.zsh.interactiveShellInit = ''
    setopt AUTOCD AUTOPUSHD

    autoload -U down-line-or-beginning-search
    autoload -U up-line-or-beginning-search
    bindkey '^[[A' down-line-or-beginning-search
    bindkey '^[[A' up-line-or-beginning-search
    zle -N down-line-or-beginning-search
    zle -N up-line-or-beginning-search
  '';

  environment.variables.FZF_DEFAULT_COMMAND = "ag -l -f -g ''";
  environment.variables.SHELLCHECK_OPTS = "-e SC1008";
  environment.variables.LANG = "en_US.UTF-8";

  environment.shellAliases.g = "git log --pretty=color -32";
  environment.shellAliases.gb = "git branch";
  environment.shellAliases.gc = "git checkout";
  environment.shellAliases.gcb = "git checkout -B";
  environment.shellAliases.gd = "git diff --minimal --patch";
  environment.shellAliases.gf = "git fetch";
  environment.shellAliases.gl = "git log --pretty=color --graph";
  environment.shellAliases.glog = "git log --pretty=nocolor";
  environment.shellAliases.grh = "git reset --hard";
  environment.shellAliases.l = "ls -lh";
  environment.shellAliases.ls = "ls -G";

  nix.nixPath =
    [ # Use local nixpkgs checkout instead of channels.
      "darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix"
      "darwin=$HOME/.nix-defexpr/darwin"
      "nixpkgs=$HOME/.nix-defexpr/nixpkgs"
      "$HOME/.nix-defexpr/channels"
      "$HOME/.nix-defexpr"
    ];

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (self: super: {
      lnl-zsh-completions = super.runCommandNoCC "lnl-zsh-completions-0.0.0"
        { preferLocalBuild = true; }
        ''
          mkdir -p $out/share/zsh/site-functions

          cat <<-'EOF' > $out/share/zsh/site-functions/_darwin-rebuild
          #compdef darwin-rebuild
          #autoload

          _nix-common-options

          local -a _1st_arguments
          _1st_arguments=(
            'switch:Build, activate, and update the current generation'\
            'build:Build without activating or updating the current generation'\
            'check:Build and run the activation sanity checks'\
            'changelog:Show most recent entries in the changelog'\
          )

          _arguments \
            '--list-generations[Print a list of all generations in the active profile]'\
            '--rollback[Roll back to the previous configuration]'\
            {--switch-generation,-G}'[Activate specified generation]'\
            '(--profile-name -p)'{--profile-name,-p}'[Profile to use to track current and previous system configurations]:Profile:_nix_profiles'\
            '1:: :->subcmds' && return 0

          case $state in
            subcmds)
              _describe -t commands 'darwin-rebuild subcommands' _1st_arguments
            ;;
          esac
          EOF
        '';
    })
  ];

  # TODO: add module for per-user config, etc, ...
  system.activationScripts.extraUserActivation.text = "ln -sfn /etc/per-user/lnl/gitconfig ~/.gitconfig";

  environment.etc."per-user/lnl/gitconfig".text = ''
    [include]
      path = .gitconfig.local

    [core]
      excludesfile = ~/.gitignore
      autocrlf     = input

    [color]
      ui = auto

    [pretty]
      color = format:%C(yellow)%h%Cblue%d%Creset %s %C(white)  %an, %ar%Creset
      nocolor = format:%h%d %s   %an, %ar

    [user]
      name = Daiderd Jordan

    [github]
      user = LnL7
  '';

  services.khd.khdConfig = ''
    # modifier only mappings
    khd mod_trigger_timeout 0.2
    lctrl  : qes -k "escape"
    lshift : qes -t "("
    rshift : qes -t ")"
  '';

  services.kwm.kwmConfig = ''
    kwmc config tiling bsp
    kwmc config split-ratio 0.5
    kwmc config spawn left

    kwmc config padding 40 15 15 15
    kwmc config gap     15 15

    kwmc config space   0 3 padding 125 125 125 125
    kwmc config display 1   padding 75 70 70 70
    kwmc config display 2   padding 75 70 70 70

    kwmc config space 0 1 name main
    kwmc config space 0 2 mode monocle
    kwmc config space 0 2 name rnd
    kwmc config space 0 3 name dev
    kwmc config space 1 1 name web
    kwmc config space 2 1 name var


    kwmc config focus-follows-mouse on
    kwmc config mouse-follows-focus on
    kwmc config standby-on-float    on
    kwmc config center-on-float     on
    kwmc config float-non-resizable on
    kwmc config lock-to-container   on
    kwmc config cycle-focus         on
    kwmc config optimal-ratio       1.605


    kwmc rule owner="Airmail" properties={float="true"}
    kwmc rule owner="Apple Store" properties={float="true"}
    kwmc rule owner="Finder" properties={role="AXDialog"}
    kwmc rule owner="Finder" role="AXDialog" properties={float="true"}
    kwmc rule owner="Info" properties={float="true"}
    kwmc rule owner="System Preferences" properties={float="true"}
    kwmc rule owner="iTerm2" properties={role="AXDialog"}
    kwmc rule owner="iTunes" properties={float="true"}
  '';

  services.skhd.package = pkgs.skhd;

  services.skhd.skhdConfig = ''
    # focus window
    alt - h : kwmc window -f west
    alt - j : kwmc window -f south
    alt - k : kwmc window -f north
    alt - l : kwmc window -f east

    # swap window
    shift + alt - h : kwmc window -s west
    shift + alt - j : kwmc window -s south
    shift + alt - k : kwmc window -s north
    shift + alt - l : kwmc window -s east

    # move window
    ctrl + alt - h : kwmc window -m west
    ctrl + alt - j : kwmc window -m south
    ctrl + alt - k : kwmc window -m north
    ctrl + alt - l : kwmc window -m east

    # send window to desktop
    ctrl + alt - 0x12 : kwmc window -m space 1
    ctrl + alt - 0x13 : kwmc window -m space 2
    ctrl + alt - 0x14 : kwmc window -m space 3

    # focus monitor
    alt - 0x12 : kwmc display -f 0
    alt - 0x13 : kwmc display -f 1
    alt - 0x14 : kwmc display -f 2

    # send window to monitor
    shift + alt - 0x12 : kwmc window -m display 0
    shift + alt - 0x13 : kwmc window -m display 1
    shift + alt - 0x14 : kwmc window -m display 2

    # toggle window fullscreen
    shift + alt - f : kwmc window -z fullscreen

    # toggle window parent zoom
    shift + alt - d : kwmc window -z parent

    # float / unfloat window and center on screen
    shift + alt - w : kwmc window -t focused

    # toggle sticky, float and resize to picture-in-picture size
    # shift + alt - s : chunkc tiling::window --toggle sticky;\
    #                   chunkc tiling::window --grid-layout 5:5:4:0:1:1

    # rotate tree
    ctrl + alt - r : kwmc tree rotate 90

    # change layout of desktop
    ctrl + alt - a : kwmc space -t bsp
    ctrl + alt - s : kwmc space -t monocle
    ctrl + alt - d : kwmc space -t float

    # quit/reload daemons
    ctrl + alt - q : kwmc quit;\
                     khd -e "reload"
  '';

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 1;
}

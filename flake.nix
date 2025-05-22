{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      environment = {
        extraInit = ''
          source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
          source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
        '';

        shellAliases = {
          vi = "nvim";
          vim = "nvim";
        };

        systemPath = [
          # GNU utils
          "/opt/homebrew/opt/gnu-getopt/bin"
          "/opt/homebrew/opt/gnu-sed/libexec/gnubin"
          "/opt/homebrew/opt/gnu-tar/libexec/gnubin"
          # PostgreSQL utils
          "/opt/homebrew/opt/libpq/bin"
        ];

        variables = {
          KUBE_EDITOR = "nvim";
        };

        systemPackages =
          [
            pkgs.curl
            pkgs.go
            pkgs.golangci-lint
            pkgs.htop
            pkgs.httpie
            pkgs.jq
            pkgs.neovim
            pkgs.neofetch
            pkgs.nodejs_22
            pkgs.odin
            pkgs.oh-my-zsh
            pkgs.pstree
            pkgs.ssh-copy-id
            pkgs.tree
            pkgs.uv
          ];
      };

      fonts.packages = [
        pkgs.nerd-fonts.hack
      ];

      homebrew = {
        enable = true;

        taps = [
          "homebrew/cask"
          "pulumi/tap"
        ];

        brews = [
          "gnu-getopt"
          "gnu-sed"
          "gnu-tar"
          "libpq"
          "poetry"
          "pre-commit"
          "pulumi/tap/pulumi"
          "python@3.10"
          "rust"
          "watch"
        ];

        casks = [
          "1password"
          "1password-cli"
          "balenaetcher"
          "dbeaver-community"
          "docker"
          "gimp"
          "google-chrome"
          "google-cloud-sdk"
          "iterm2"
          "jetbrains-toolbox"
          "karabiner-elements"
          "openemu"
          "raspberry-pi-imager"
          "rustdesk"
          "signal"
          "slack"
          "steam"
          "tidal"
          "twingate"
          "vlc"
          "yaak"
        ];

        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "zap";
        };
      };

      nix = {
        settings = {
          # Necessary for using flakes on this system.
          experimental-features = "nix-command flakes";
          trusted-users = [ "alex" ];
        };
        gc = {
          automatic = true;
          interval = { Weekday = 0; Hour = 2; Minute = 0; };
          options = "--delete-older-than 30d";
        };
      };

      nixpkgs = {
        config = {
         # allowUnfree is required to install some packages that are not "free" software.
        allowUnfree = true;
        };
        hostPlatform = "aarch64-darwin";
      };

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh = {
        enableCompletion = true;
        enableSyntaxHighlighting = true;
      };

      # Enable fingerprint authentication for sudo commands
      security.pam.services.sudo_local.touchIdAuth = true;

      system = {
        primaryUser = "alex";

        # Set Git commit hash for darwin-version.
        configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        stateVersion = 6;

        defaults = {
          dock = {
            autohide  = true;
            magnification = false;
            mineffect = "genie";
            mru-spaces = false; # Most Recently Used spaces.
            show-recents = false;
          };

          finder = {
            AppleShowAllExtensions = true;
            FXPreferredViewStyle = "Nlsv"; # list view. https://macos-defaults.com/finder/fxpreferredviewstyle.html
            ShowPathbar = true; # Show path bar in Finder
          };

          loginwindow.GuestEnabled  = false;

          NSGlobalDomain = {
            "com.apple.sound.beep.volume" = 0.0;
            "com.apple.sound.beep.feedback" = 0;
            AppleInterfaceStyle = "Dark";
            ApplePressAndHoldEnabled = false;
            InitialKeyRepeat = 15;
            KeyRepeat = 2;
          };

          screencapture.location = "~/Pictures";
        };
      };
    };
  in
  {
    darwinConfigurations."mac-10" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
      ];
    };
  };
}

{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-services = {
      url = "github:homebrew/homebrew-services";
      flake = false;
    };
    pulumi-tap = {
      url = "github:pulumi/homebrew-tap";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, homebrew-services, pulumi-tap }:
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

        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # allowUnfree is required to install some packages that are not "free" software.
      nixpkgs.config.allowUnfree = true;

      nixpkgs.hostPlatform = "aarch64-darwin";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh = {
        enableCompletion = true;
        enableSyntaxHighlighting = true;
      };

      # Enable fingerprint authentication for sudo commands
      security.pam.services.sudo_local.touchIdAuth = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      system.defaults = {
        dock.autohide  = true;
        dock.magnification = false;
        dock.mineffect = "genie";
        dock.mru-spaces = false; # Most Recently Used spaces.
        dock.show-recents = false;

        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "Nlsv"; # list view. https://macos-defaults.com/finder/fxpreferredviewstyle.html
        finder.ShowPathbar = true; # Show path bar in Finder

        loginwindow.GuestEnabled  = false;

        NSGlobalDomain."com.apple.sound.beep.volume" = 0.0;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.ApplePressAndHoldEnabled = false;
        NSGlobalDomain.InitialKeyRepeat = 15;
        NSGlobalDomain.KeyRepeat = 2;

        screencapture.location = "~/Pictures";
      };
    };
  in
  {
    darwinConfigurations."mac-10" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "alex";

            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-bundle" = homebrew-bundle;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-services" = homebrew-services;
              "pulumi/tap" = pulumi-tap;
            };

            mutableTaps = true;
          };
        }
      ];
    };
  };
}

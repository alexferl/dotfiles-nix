{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
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

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, homebrew-services, pulumi-tap }:
  let
    configuration = { pkgs, ... }: {
       fonts.packages = [
         pkgs.nerd-fonts.hack
       ];

      environment.systemPackages =
        [
          pkgs.curl
          pkgs.go
          pkgs.golangci-lint
          pkgs.google-chrome
          (pkgs.google-cloud-sdk.withExtraComponents [
            pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
          ])
          pkgs.htop
          pkgs.httpie
          pkgs.iterm2
          pkgs.jetbrains-toolbox
          pkgs.jq
          pkgs.karabiner-elements
          pkgs.neovim
          pkgs.nodejs_22
          pkgs.odin
          pkgs.rustc
          pkgs.rustup
          pkgs.slack
          pkgs.ssh-copy-id
          pkgs.tree
          pkgs.uv
          pkgs.vim
          pkgs.vlc-bin
          pkgs.wget
        ];

      homebrew = {
        enable = true;

         brews = [
           "gnu-getopt"
           "gnu-sed"
           "gnu-tar"
           "poetry"
           "pre-commit"
           "pulumi/tap/pulumi"
           "python@3.10"
         ];

        casks = [
          "1password"
          "1password-cli"
          "balenaetcher"
          "dbeaver-community"
          "docker"
          "gimp"
          "openemu"
          "rustdesk"
          "signal"
          "steam"
          "tidal"
          "twingate"
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
      programs.zsh.enable = true;

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

        loginwindow.GuestEnabled  = false;

        NSGlobalDomain."com.apple.sound.beep.volume" = 0.0;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.ApplePressAndHoldEnabled = true;
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
        mac-app-util.darwinModules.default
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

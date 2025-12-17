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
          source "/opt/homebrew/Caskroom/gcloud-cli/latest/google-cloud-sdk/path.zsh.inc"
          source "/opt/homebrew/Caskroom/gcloud-cli/latest/google-cloud-sdk/completion.zsh.inc"
        '';

        shellAliases = {
          vi = "nvim";
          vim = "nvim";
        };

        systemPath = [
          # Homebrew paths
          "/opt/homebrew/bin"
          "/opt/homebrew/sbin"
          # GNU utils
          "/opt/homebrew/opt/gnu-getopt/bin"
          "/opt/homebrew/opt/gnu-sed/libexec/gnubin"
          "/opt/homebrew/opt/gnu-tar/libexec/gnubin"
          # PostgreSQL utils
          "/opt/homebrew/opt/libpq/bin"
          # Custom scripts
          "/Users/alex/dev/nix/dotfiles-nix/scripts"
        ];

        variables = {
          EDITOR = "nvim";
          KUBE_EDITOR = "nvim";
          VISUAL = "nvim";
        };

        systemPackages =
          [
            pkgs.oh-my-zsh
          ];
      };

      fonts.packages = [
        pkgs.nerd-fonts.hack
      ];

      homebrew = {
        enable = true;

        taps = [
          "mongodb/brew"
          "pulumi/tap"
        ];

        brews = [
          "aria2"
          "awscli"
          "coreutils"
          "curl"
          "glab"
          "gnu-getopt"
          "gnu-sed"
          "gnu-tar"
          "go"
          "golangci-lint"
          "gopls"
          "htop"
          "httpie"
          "jq"
          "libmagic"
          "libpq"
          "llvm"
          "mas"
          "mkcert"
          "mongodb/brew/mongodb-community"
          "neovim"
          "neofetch"
          "node"
          "odin"
          "poetry"
          "pre-commit"
          "pstree"
          "pulumi/tap/pulumi"
          "python@3.10"
          "rust"
          "ssh-copy-id"
          "tree"
          "uv"
          "watch"
          "wget"
        ];

        casks = [
          "1password"
          "1password-cli"
          "ableton-live-intro"
          "applepi-baker"
          "balenaetcher"
          "dbeaver-community"
          "gcloud-cli"
          "gimp"
          "google-chrome"
          "inmusic-software-center"
          "iterm2"
          "jetbrains-toolbox"
          "karabiner-elements"
          "orbstack"
          "raspberry-pi-imager"
          "retroarch-metal"
          "signal"
          "slack"
          "spotify"
          "steam"
          "telegram"
          "twingate"
          "vlc"
          "yaak"
        ];

        masApps = {
          WireGuard = 1451685025;
        };

        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "zap";
        };
      };

      launchd.daemons.limit-maxfiles = {
        serviceConfig = {
          Label = "limit.maxfiles";
          ProgramArguments = [
            "launchctl"
            "limit"
            "maxfiles"
            "10240"
            "unlimited"
          ];
          RunAtLoad = true;
        };
      };

      nix = {
        gc = {
          automatic = true;
          interval = { Weekday = 0; Hour = 2; Minute = 0; };
          options = "--delete-older-than 30d";
        };
        settings = {
          # Necessary for using flakes on this system.
          experimental-features = "nix-command flakes";
          trusted-users = [ "alex" ];
        };
      };

      nixpkgs = {
        config = {
          # allowUnfree is required to install some packages that are not "free" software.
          allowUnfree = true;
        };
        hostPlatform = "aarch64-darwin";
      };

      programs = {
        zsh = {
          # Enable zsh completion for all interactive zsh shells.
          enableCompletion = true;

          # Enable zsh-syntax-highlighting.
          enableSyntaxHighlighting = true;
        };
      };

      # Enable fingerprint authentication for sudo commands
      security.pam.services.sudo_local.touchIdAuth = true;

      networking = {
        applicationFirewall = {
          enable = true;
          allowSigned = true;
          allowSignedApp = true;
          blockAllIncoming = true;
        };
      };

      system = {
        primaryUser = "alex";

        # Set Git commit hash for darwin-version.
        configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        stateVersion = 6;

        defaults = {
          dock = {
            # Whether to automatically hide and show the dock.
            autohide  = true;

            # Magnify icon on hover.
            magnification = false;

            # Set the minimize/maximize window effect.
            # "genie", "suck", "scale"
            mineffect = "genie";

            # Whether to automatically rearrange spaces based on most recent use.
            mru-spaces = false;

            # Persistent applications, spacers, files, and folders in the dock.
            persistent-apps = [
              {
                app = "/Applications/iTerm.app";
              }
              {
                app = "/Users/alex/Applications/IntelliJ IDEA.app";
              }
              {
                app = "/Applications/Google Chrome.app";
              }
              {
                app = "/Applications/Slack.app";
              }
              {
                app = "/Applications/Signal.app";
              }
              {
                app = "/Applications/Spotify.app";
              }
              {
                app = "/System/Applications/System Settings.app";
              }
            ];
            # Persistent folders in the dock.
            persistent-others = [
               { folder = { path = "/Users/alex"; displayas = "folder"; showas = "list"; }; }
               { folder = { path = "/Applications"; displayas = "folder"; showas = "list"; }; }
            ];
            # Show recent applications in the dock.
            show-recents = false;
          };

          finder = {
            # Whether to show all file extensions in Finder.
            AppleShowAllExtensions = true;

            # Whether to always show hidden files.
            AppleShowAllFiles = true;

            # Change the default finder view.
            # "icnv" = Icon view, "Nlsv" = List view, "clmv" = Column View, "Flwv" = Gallery View
            FXPreferredViewStyle = "Nlsv";

            # Show path breadcrumbs in finder windows.
            ShowPathbar = true;
          };

          loginwindow = {
            # Allow users to login to the machine as guests using the Guest account.
            GuestEnabled  = false;
          };

          NSGlobalDomain = {
            # Make a feedback sound when the system volume changed. This setting accepts the integers 0 or 1.
            "com.apple.sound.beep.feedback" = 0;

            # Sets the beep/alert volume level from 0.000 (muted) to 1.000 (100% volume).
            "com.apple.sound.beep.volume" = 0.0;

            AppleInterfaceStyle = "Dark";

            # Whether to enable the press-and-hold feature.
            ApplePressAndHoldEnabled = false;

            # This sets how long you must hold down the key before it starts repeating.
            InitialKeyRepeat = 15;

            # This sets how fast it repeats once it starts.
            KeyRepeat = 2;
          };

          screencapture = {
            # The filesystem path to which screencaptures should be written.
            location = "~/Pictures";
          };
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

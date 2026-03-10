{
  description = "Katou's Desktop";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    gnome2.url = "path:./gnome2-revived-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      gnome2,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        config.allowUnfree = true;
        inherit system;
      };
    in
    {
      packages.${system} = rec {
        dev-tools = pkgs.buildEnv {
          name = "dev-tools";
          paths = with pkgs; [
            vscode
            git
          ];
        };

        general-tools = pkgs.buildEnv {
          name = "general-tools";
          paths = with pkgs; [
            wget
            ripgrep
          ];
        };

        net-tools = pkgs.buildEnv {
          name = "net-tools";
          paths = with pkgs; [ netbird ];
        };

        desktop-apps = pkgs.buildEnv {
          name = "desktop-apps";
          paths = with pkgs; [
            telegram-desktop
            (discord.override { withOpenASAR = true; })
            darktable
            xnviewmp
            deluge
            nicotine-plus
            obs-studio
            picard
            spek
            wpsoffice
            terminator
          ];
        };

        nixosConfigurations.katous-desktop = gnome2.nixosConfigurations.gnomevm.extendModules {
          modules = [
            (
              { programs, ... }:
              {
                environment.systemPackages = [
                  self.packages.${system}.dev-tools
                  self.packages.${system}.general-tools
                  self.packages.${system}.desktop-apps
                  self.packages.${system}.net-tools
                ];

                # Need 2 specify it twice..
                nixpkgs.config.allowUnfree = true;

                # Enable steam, we WILL be playing deadlock
                programs.steam.enable = true;

                # Enable appimages, discord-music-rpc my love
                programs.appimage.enable = true;
                programs.appimage.binfmt = true;

                # Let us pipe those wires
                services.pipewire = {
                  enable = true;
                  pulse.enable = true;
                  alsa.enable = true;
                  alsa.support32Bit = true;
                };

                # I fuck heavy with the flakes
                nix.settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];

              }
            )
          ];
        };
      };
    };
}

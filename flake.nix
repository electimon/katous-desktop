{
  description = "Katou's Desktop";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    gnome2.url = "path:./gnome2-revived-nix";
    ayu = { type = "git"; submodules = true; url = "https://github.com/ndfined-crp/ayugram-desktop/"; };
#    compiz = { type = "git"; url = "https://github.com/electimon/compiz-reloaded-nix"; inputs.nixpkgs.follows = "nixpkgs"; rev = "e31d950f319fe17ada8d07ca74076bcee52d774c"; };
    compiz.url = "path:/home/katou/Downloads/compiz-reloaded-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      gnome2,
      ayu,
      compiz,
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
            ffmpeg
            unzip
            alsa-utils
            uv
          ];
        };

        bitchass-miscs = pkgs.buildEnv {
          name = "miscs";
          paths = with pkgs; [
            gsettings-desktop-schemas
            (pango.override { withIntrospection = true; })
          ];
        };

        fonts = pkgs.buildEnv {
          name = "fonts";
          paths = with pkgs; [
            liberation_ttf
            font-adobe-75dpi
            font-adobe-100dpi
            ubuntu-sans
            ubuntu-classic
            libertine
            terminus_font_ttf
          ];
        };

        net-tools = pkgs.buildEnv {
          name = "net-tools";
          paths = with pkgs; [ netbird ];
        };

        desktop-apps = pkgs.buildEnv {
          name = "desktop-apps";
          paths = with pkgs; [
            ayu.packages.${system}.ayugram-desktop
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
            vivaldi
            compiz.packages.${system}.compiz-reloaded
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
                  self.packages.${system}.bitchass-miscs
                  self.packages.${system}.fonts
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

                # UV
                programs.nix-ld.enable = true;

              }
            )
          ];
        };
      };
    };
}

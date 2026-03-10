{
  description = "Katou's Desktop";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    gnome2.url = "path:./gnome2-revived-nix";
  };

  outputs = { self, nixpkgs, gnome2, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { config.allowUnfree = true; inherit system; };
  in {
    packages.${system} = rec {
    dev-tools = pkgs.buildEnv {
      name = "dev-tools";
      paths = with pkgs; [
        vscode
        git
        ripgrep
      ];
    };

    nixosConfigurations.katous-desktop = gnome2.nixosConfigurations.gnomevm.extendModules {
      modules = [
        ({ ... }: {
          environment.systemPackages = [
            self.packages.${system}.dev-tools
          ];
        })
      ];
    };
  };};
}

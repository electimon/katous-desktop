{
  description = "GNOME2 revived";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    gnome2.url = "path:./gnome2-revived-nix";
  };

  outputs = { self, nixpkgs, gnome2, ... }:
  {
    nixosConfigurations.katous-desktop = gnome2.nixosConfigurations.gnomevm;
  };
}

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    # sops-nix.url = "github:Mic92/sops-nix/bd695cc4d0a5e1bead703cc1bec5fa3094820a81";
  };

  outputs =
    { nixpkgs, disko, ... }:
    let
      serverModules = [
        disko.nixosModules.disko
        ./host/configuration.nix
        ./host/hardware-configuration.nix
      ];
      server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = serverModules;
      };
    in
    {
      # `nixos` kept as an alias for existing deploy scripts; both point at the same system.
      nixosConfigurations.default = server;
      nixosConfigurations.nixos = server;
    };
}

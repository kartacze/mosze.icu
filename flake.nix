{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # sops-nix.url = "github:Mic92/sops-nix/bd695cc4d0a5e1bead703cc1bec5fa3094820a81";
  };

  outputs = { nixpkgs, disko, ... }: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        ./host/configuration.nix
        ./host/hardware-configuration.nix
      ];
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # gicz-server.outputs.packages.x86_64-linux.nixosModule
        disko.nixosModules.disko

        ./host/configuration.nix
        ./host/hardware-configuration.nix
      ];
    };
  };
}

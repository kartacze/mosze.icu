{ modulesPath, lib, pkgs, ... }@args: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages =
    map lib.lowPrio [ pkgs.curl pkgs.gitMinimal pkgs.neovim ];

  users.users.root.initialPassword = "987654321asdf";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGVcFY/yyrBFoEHfJswHYqI/A52Sw+Zg43HzA+I5+Rts"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5X3sPc15vP/7Us0WVa/3+amgFyfueQZjhQ3KWal3aJ"
  ];

  networking.interfaces.ens3 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "193.33.111.100";
      prefixLength = 24;
    }];
  };
  networking.defaultGateway = "193.33.111.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];

  system.stateVersion = "24.05";
}

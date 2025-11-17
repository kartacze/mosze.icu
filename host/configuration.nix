{ modulesPath, lib, pkgs, ... }@args: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./../modules/website.nix

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

  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.neovim
    pkgs.pgcli
    pkgs.direnv
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGVcFY/yyrBFoEHfJswHYqI/A52Sw+Zg43HzA+I5+Rts"
  ];

  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];

  mosze = { website.enabled = true; };

  system.stateVersion = "24.05";
}

{ modulesPath, lib, pkgs, ... }@args: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./../modules/website.nix
    ./../modules/livebook.nix

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

  networking.firewall.allowedTCPPorts = [ 22 80 443 20123 ];

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
    pkgs.tmux
    pkgs.livebook
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGVcFY/yyrBFoEHfJswHYqI/A52Sw+Zg43HzA+I5+Rts"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5X3sPc15vP/7Us0WVa/3+amgFyfueQZjhQ3KWal3aJ"
  ];

  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];

  mosze = {
    website.enable = true;
    livebook.enable = true;
  };

  system.stateVersion = "24.05";
}

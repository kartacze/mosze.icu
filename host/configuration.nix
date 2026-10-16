{ modulesPath, lib, pkgs, ... }@args: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./../modules/website.nix
    ./../modules/livebook.nix
    ./../modules/actual-budget.nix
  ];

  networking.hostName = "mosze";

  networking.interfaces.ens3 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "193.33.111.100";
      prefixLength = 24;
    }];
  };
  networking.defaultGateway = "193.33.111.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];

  # Only 22/80/443 public. App ports (5006, 20123) stay behind nginx on localhost.
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  boot.loader.grub = {
    # No `devices`/`device` here on purpose: disko adds disks with an EF02 partition automatically.
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  # efiInstallAsRemovable => no NVRAM writes needed (works on cloud VMs without EFI vars).
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "prohibit-password";
    PasswordAuthentication = false;
  };

  time.timeZone = "Europe/Warsaw";

  # ACME centralised here so livebook/actual-budget vhosts don't depend on website.nix.
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "teodor.pytka@gmail.com";
  users.users.nginx.extraGroups = [ "acme" ];

  services.fail2ban.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.neovim
    pkgs.pgcli
    pkgs.direnv
    pkgs.livebook
  ];

  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGVcFY/yyrBFoEHfJswHYqI/A52Sw+Zg43HzA+I5+Rts"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5X3sPc15vP/7Us0WVa/3+amgFyfueQZjhQ3KWal3aJ"
  ];

  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];

  mosze = {
    website.enable = true;
    livebook.enable = true;
    actualBudget.enable = true;
  };

  system.stateVersion = "24.05";
}

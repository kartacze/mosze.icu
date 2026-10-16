{
  lib,
  config,
  pkgs,
  ...
}:
{

  options = {
    mosze.livebook.enable = lib.mkEnableOption "enables livebook";
  };

  config = lib.mkIf config.mosze.livebook.enable {

    users.users.livebook = {
      createHome = false;
      isNormalUser = true;
      group = "users";
      # Required: enableUserService is a user unit, without linger it never starts on boot.
      linger = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGVcFY/yyrBFoEHfJswHYqI/A52Sw+Zg43HzA+I5+Rts"
      ];
    };

    services.livebook = {
      enableUserService = true;
      extraPackages = with pkgs; [
        gcc
        gnumake
      ];

      environment = {
        LIVEBOOK_PORT = 20123;
        LIVEBOOK_IP = "127.0.0.1";
      };
      # Secrets (LIVEBOOK_PASSWORD / LIVEBOOK_COOKIE) go here, one VAR=value per line.
      # systemd fails the unit if this file is missing, so ensure it exists (see tmpfiles below).
      environmentFile = "/var/lib/livebook.env";
    };

    # Create an empty env file on first boot so the unit never fails on a missing file.
    # Fill in LIVEBOOK_PASSWORD afterwards and `systemctl restart livebook --user --machine=livebook@`.
    systemd.tmpfiles.rules = [ "f /var/lib/livebook.env 0600 livebook users - -" ];

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."live.zivix.pl" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:20123/";
          proxyWebsockets = true; # needed if you need to use WebSocket
        };
      };
    };
  };
}

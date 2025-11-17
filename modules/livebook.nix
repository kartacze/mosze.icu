{ lib, config, pkgs, ... }: {

  options = { mosze.livebook.enable = lib.mkEnableOption "enables livebook"; };

  config = lib.mkIf config.mosze.livebook.enable {

    users.users.livebook = {
      createHome = false;
      isNormalUser = true;
      group = "users";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGVcFY/yyrBFoEHfJswHYqI/A52Sw+Zg43HzA+I5+Rts"
      ];
    };

    services.livebook = {
      enableUserService = true;
      extraPackages = with pkgs; [ gcc gnumake ];

      environment = {
        # LIVEBOOK_PORT = 20123;
        # LIVEBOOK_APP_SERVICE_NAME = "live.mosze.icu";
        # LIVEBOOK_FORCE_SSL_HOST = true;
      };
      # See note below about security
      environmentFile = "/var/lib/livebook.env";
    };

    services.nginx = {
      virtualHosts."live.mosze.icu" = {
        useACMEHost = "mosze.icu";
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:20123/";
      };
    };
  };
}

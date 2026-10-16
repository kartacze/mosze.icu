{ lib, config, ... }: {

  options = { mosze.website.enable = lib.mkEnableOption "enables website"; };

  config = lib.mkIf config.mosze.website.enable {

    users.users.website = {
      createHome = false;
      isNormalUser = true;
      group = "users";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGVcFY/yyrBFoEHfJswHYqI/A52Sw+Zg43HzA+I5+Rts"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5X3sPc15vP/7Us0WVa/3+amgFyfueQZjhQ3KWal3aJ"
      ];
    };

    # ACME defaults live in host/configuration.nix so every vhost can use enableACME.

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."zivix.pl" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          return = "200 '<html><body>It works</body></html>'";
          extraConfig = ''
            default_type text/html;
          '';
        };

      };
    };
  };
}

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

    security.acme.acceptTerms = true;
    security.acme.defaults.email = "teodor.pytka@gmail.com";

    users.users.nginx.extraGroups = [ "acme" ];

    services.nginx = {
      enable = true;
      # recommendedProxySettings = true;
      # recommendedTlsSettings = true;

      virtualHosts."mosze.icu" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          # proxyPass = "http://127.0.0.1:4000";
          # extraConfig = ''
          #   proxy_set_header Host $host;
          #   proxy_set_header X-Real-IP $remote_addr;
          #   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          #   proxy_set_header X-Forwarded-Proto $scheme;
          # '';
          return = "200 '<html><body>It works</body></html>'";
          extraConfig = ''
            default_type text/html;
            proxy_ssl_server_name on;
            proxy_pass_header Authorization;
          '';
        };

      };

      # virtualHosts."live.mosze.icu" = {
      #   useACMEHost = "mosze.icu";
      #   forceSSL = true;
      #   locations."/" = {
      #     proxyPass = "http://localhost:20123/";
      #     extraConfig = ''
      #       proxy_set_header Host $host;
      #       proxy_set_header X-Real-IP $remote_addr;
      #       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      #       proxy_set_header X-Forwarded-Proto $scheme;
      #     '';
      #   };
      # };
      #
      # virtualHosts."test.mosze.icu" = {
      #   useACMEHost = "mosze.icu";
      #   forceSSL = true;
      #   locations."/" = {
      #     proxyPass = "http://localhost:20123/";
      #     proxyWebsockets = true; # needed if you need to use WebSocket
      #     extraConfig =
      #       # required when the target is also TLS server with multiple hosts
      #       "proxy_ssl_server_name on;" +
      #       # required when the server wants to use HTTP Authentication
      #       "proxy_pass_header Authorization;";
      #     # extraConfig = ''
      #     #   proxy_set_header Host $host;
      #     #   proxy_set_header X-Real-IP $remote_addr;
      #     #   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      #     #   proxy_set_header X-Forwarded-Proto $scheme;
      #     # '';
      #   };
      # };
    };
  };
}

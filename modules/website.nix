{ lib, config, ... }: {

  options = { mosze.website.enable = lib.mkEnableOption "enables website"; };

  config = lib.mkIf config.mosze.website.enable {

    users.users.website = {
      createHome = false;
      isNormalUser = true;
      group = "users";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGVcFY/yyrBFoEHfJswHYqI/A52Sw+Zg43HzA+I5+Rts"
      ];
    };

    security.acme.acceptTerms = true;
    security.acme.defaults.email = "teodor.pytka@gmail.com";

    users.users.nginx.extraGroups = [ "acme" ];

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."mosze.icu" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          # proxyPass = "http://127.0.0.1:4000";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
          return = "200 '<html><body>It works</body></html>'";
          # extraConfig = ''
          #   default_type text/html;
          #   proxy_ssl_server_name on;
          #   proxy_pass_header Authorization;
          # '';
        };
      };
    };

    # Make sure the "website" user has access to /srv/website
    # systemd.tmpfiles.rules = [ "d /srv/website 0750 website nginx" ];

    # Make sure acme module is active for the "kyren.codes" ssl cert

    # services.nginx.enable = true;
    # services.nginx.virtualHosts."kyren.codes" = {
    #   useACMEHost = "kyren.codes";
    #   forceSSL = true;
    #   locations."/" = {
    #     index = "index.html";
    #     root = "/srv/website";
    #   };
    #
    #   locations."/404.html" = { root = "/srv/website"; };
    #   extraConfig = ''
    #     error_page 404 /404.html;
    #   '';
    # };
  };
}

{ lib, config, pkgs, ... }: {

  options = {
    mosze.actualBudget.enable = lib.mkEnableOption "enables livebook";
  };

  config = lib.mkIf config.mosze.actualBudget.enable {

    services.actual.enable = true;
    services.actual.settings.port = 5006;

    # Open https port to the public
    networking.firewall.allowedTCPPorts = [ 443 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    # acme.enable = true;

    # services.nginx.virtualHosts."budget.kyren.codes" = {
    #   useACMEHost = "kyren.codes";
    #   forceSSL = true;
    #   locations."/".proxyPass = "http://localhost:5006/";
    # };

    services.nginx = {
      enable = true;
      virtualHosts."actual.mosze.icu" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://localhost:5006/";

          # extraConfig = ''
          #   proxy_set_header Host $host;
          #   proxy_set_header X-Real-IP $remote_addr;
          #   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          #   proxy_set_header X-Forwarded-Proto $scheme;
          # '';
        };
      };
    };
  };
}

{
  lib,
  config,
  ...
}:
{

  options = {
    mosze.actualBudget.enable = lib.mkEnableOption "enables actual-budget";
  };

  config = lib.mkIf config.mosze.actualBudget.enable {

    services.actual.enable = true;
    services.actual.settings.port = 5006;

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."actual.zivix.pl" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:5006/";
          proxyWebsockets = true;
        };
      };
    };
  };
}

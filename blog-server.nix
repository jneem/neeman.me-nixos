{ wwwRoot }:
{ pkgs, ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts."joe.neeman.me" = {
      forceSSL = true;
      enableACME = true;
      root = wwwRoot;
    };
  };

}


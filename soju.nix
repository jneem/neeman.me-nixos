{ config, pkgs, ... }:
let localPort = 6667;
    exposedPort = 6697;
in
{
  services.soju = {
    enable = true;
    # halloy "strongly recommends" using the db, but the nixos module doesn't support it
    configFile = pkgs.writeText "soju.conf" ''
      listen irc+insecure://127.0.0.1:6667
      listen unix+admin:///run/soju/admin
      hostname ://joe.neeman.me

      message-store db
      http-origin
      accept-proxy-ip
    '';
  };
  services.nginx = {
    enable = true;
    streamConfig =
    let certDir = config.security.acme.certs."joe.neeman.me".directory; in
    ''
      server {
        listen ${toString exposedPort} ssl;
        listen [::]:${toString exposedPort} ssl;
        ssl_certificate ${certDir}/fullchain.pem;
        ssl_certificate_key ${certDir}/key.pem;
        proxy_pass 127.0.0.1:${toString localPort};
      }
    '';
  };
  networking.firewall.allowedTCPPorts = [ exposedPort ];
}

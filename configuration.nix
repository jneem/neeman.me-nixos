{ pkgs, config, ... }:
{
  imports = [
    ./restic.nix
  ];

  nix = {
    #registry.nixpkgs.flake = nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "treeman-ranch-nixos";
  networking.domain = "";
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGpAveBRfqrg7a41+qdOxw5WT3CbEi7dwlgKObSM85YP"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3Hjr4Dv+5hKLBzAxO83oiNHA0ZmaG0/LINPVOKs9+4"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKq2IwKZB9xrJyVhSgomBsZQfGrjBVT8PFa6j7iCvT8t"
  ];

  time.timeZone = "America/Chicago";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };

  mailserver = {
    enable = true;
    fqdn = "mail.neeman.me";
    domains = [ "neeman.me" ];

    accounts = {
      "joe@neeman.me" = {
        hashedPasswordFile = builtins.path { path = ./secrets/mail_joe.txt; };
        aliases = ["postmaster@neeman.me"];
      };
    };

    x509.useACMEHost = config.mailserver.fqdn;
    stateVersion = 3;
  };

  services.nginx = {
    enable = true;
    virtualHosts.${config.mailserver.fqdn}.enableACME = true;
  };

}

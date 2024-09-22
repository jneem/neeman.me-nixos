{ pkgs, ... }:
let
  pythonVolEnv = pkgs.python3.withPackages (ps: with ps; [
    numpy
    pandas
    yfinance
    pyarrow
  ]);
in
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
  services.openssh.enable = true;
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

  systemd.timers."vol-scrape" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "Mon..Fri *-*-* 07..16/1:00,10,20,30,40,50";
      Unit = "vol-scrape.service";
    };
  };

  systemd.services."vol-scrape" = {
    script = ''
      set -eu
      ${pythonVolEnv}/bin/python3 /root/vol/scrape.py
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.neeman.me";
    domains = [ "neeman.me" ];

    loginAccounts = {
      "joe@neeman.me" = {
        hashedPasswordFile = "/var/lib/secrets/email_joe";
        aliases = ["postmaster@neeman.me"];
      };
    };

    certificateScheme = "acme-nginx";
  };
}

{ pkgs, ... }:
let
  pythonVolEnv = pkgs.python3.withPackages (ps: with ps; [
    numpy
    pandas
    pyarrow
    yfinance
  ]);
in
{
  imports = [
    
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

  systemd.timers.volScrape = {
    enable = true;
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "vol-scrape";
      OnCalendar = "Mon..Fri *-*-* 7..16:00,10,20,30,40,50:* America/Chicago";
    };
  };

  systemd.services.volScrape = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      set -eu
      ${pythonVolEnv}/bin/python3 /root/vol/scrape.py
    '';
  };
}

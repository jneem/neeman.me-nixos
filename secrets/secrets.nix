let
  neeman_me_host_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMxFhwMiEhO7wNyTT24gsY8Nkc7g6Qj4yylMKL5AnpxE";
  caravan_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3Hjr4Dv+5hKLBzAxO83oiNHA0ZmaG0/LINPVOKs9+4";
in
{
  "restic/env.age".publicKeys = [ neeman_me_host_key caravan_key ];
  "restic/repo.age".publicKeys = [ neeman_me_host_key caravan_key ];
  "restic/password.age".publicKeys = [ neeman_me_host_key caravan_key ];
}

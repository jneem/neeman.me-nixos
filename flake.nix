{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    blog.url = "github:jneem/blog";
  };

  outputs = { nixpkgs, flake-utils, ... }@inputs:
    let
      wwwRoot = inputs.blog.packages.aarch64-linux.default;
    in {
      nixosConfigurations.treeman-ranch = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        modules = [
          (import ./configuration.nix)
          (import ./hardware-configuration.nix)
          (import ./networking.nix) # generated at runtime by nixos-infect
          (import ./blog-server.nix { inherit wwwRoot; })
          {
            system.stateVersion = "23.05";
          }
        ];
      };
    };
}

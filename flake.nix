{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    blog.url = "github:jneem/blog";
  };

  outputs = { nixpkgs, flake-utils, ... }@inputs:
    let
      # TODO: figure out how to have this in cachix
      wwwRoot = inputs.blog.packages.aarch64-linux.default;
    in {
      nixosConfigurations.treeman-ranch = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        modules = [
          (import ./configuration.nix)
          (import ./blog-server.nix { inherit wwwRoot; })
          {
            system.stateVersion = "23.05";
          }
        ];
      };
    };
}

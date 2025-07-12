{
  description = "A half-baked fullstack Rust HATEOAS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import rust-overlay)
            (final: prev: {
              rustUtils = import ./nix/rustUtils.nix {
                inherit rust-overlay;
                pkgs = prev;
              };
            })
          ];
        };
      in
      {
        devShells = import ./nix/devShells/default.nix { inherit pkgs; };
      }
    );
}

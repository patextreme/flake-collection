{
  description = "Personal collection of handy flake components";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    {
      templates = import ./templates;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.unfree = true;
          overlays = [ (import rust-overlay) ];
        };
      in
      {
        apps.format = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "fmt" ''
              find . | grep '\.nix$' | xargs -I _ bash -c "echo \"formatting _\" && ${pkgs.nixfmt-rfc-style}/bin/nixfmt _"
            ''
          );
        };

        packages = (import ./packages/rust.nix { inherit pkgs; });
      }
    );
}

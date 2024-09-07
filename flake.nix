{
  description = "My collection of flake packages when upstream doesn't provide one";

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
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.unfree = true;
          overlays = [ (import rust-overlay) ];
        };
        rust = pkgs.rust-bin.nightly."2024-09-06".default.override {
          extensions = [ ];
          targets = [ ];
        };
        rustPlatform = pkgs.makeRustPlatform {
          cargo = rust;
          rustc = rust;
        };
      in
      {
        packages = {
          loco-cli = rustPlatform.buildRustPackage rec {
            pname = "loco";
            version = "v0.8.1"; # loco-cli version might be different, but it's fine

            src = pkgs.fetchFromGitHub {
              owner = "loco-rs";
              repo = "loco";
              rev = version;
              hash = "sha256-bAj9850tKxwuDmGFRBUWvagnreYDScy99lBpMrSE764=";
              sparseCheckout = [ "loco-cli" ];
            };

            sourceRoot = "${src.name}/loco-cli";
            cargoLock.lockFile = ./cargo-locks/loco-cli.lock;

            postPatch = ''
              ln -s ${cargoLock.lockFile} Cargo.lock
            '';
          };
        };
      }
    );
}

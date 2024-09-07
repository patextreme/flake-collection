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
        devShells.default = pkgs.mkShell { packages = [ rust ]; };

        packages = {
          loco-cli = rustPlatform.buildRustPackage rec {
            pname = "loco-cli";
            version = "0.2.7";

            src = pkgs.fetchCrate {
              inherit pname version;
              hash = "sha256-GuOsTFahB9Ln22jBT4EShVthKs8LXytXltV47KJGZZI=";
            };

            cargoHash = "sha256-3XLlGJnQgA3WZyjPIv+EBwFobFiMAsvVNNd75Z02AnY=";
          };

          sea-orm-cli = rustPlatform.buildRustPackage rec {
            pname = "sea-orm-cli";
            version = "1.0.1";

            src = pkgs.fetchCrate {
              inherit pname version;
              hash = "sha256-b1Nlt3vsLDajTiIW9Vn51Tv9gXja8/ZZBD62iZjh3KY=";
            };

            nativeBuildInputs = with pkgs; [ pkg-config ];

            buildInputs = with pkgs; [ openssl ]
              ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.darwin.apple_sdk.frameworks.SystemConfiguration ];

            cargoHash = "sha256-ZGM+Y67ycBiukgEBUq+WiA1OUCGahya591gM6CGwzMQ=";
          };
        };
      }
    );
}

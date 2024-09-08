{
  description = "A devShell example";

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
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rust = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
          ];
          targets = [ ];
        };
      in
      {
        devShells.default =
          let
            rootDir = "$ROOT_DIR";
            scripts =
              let
                localDb = {
                  port = 5432;
                  username = "postgres";
                  password = "postgres";
                  dbName = "postgres";
                };
              in
              {
                format = pkgs.writeShellScriptBin "format" ''
                  cd ${rootDir}
                  find ${rootDir} | grep '\.nix$' | xargs -I _ bash -c "echo running nixfmt on _ && ${pkgs.nixfmt-rfc-style}/bin/nixfmt _"
                  find ${rootDir} | grep '\.toml$' | xargs -I _ bash -c "echo running taplo on _ && ${pkgs.taplo}/bin/taplo format _"
                  ${rust}/bin/cargo fmt
                '';

                dbUp = pkgs.writeShellScriptBin "dbUp" ''
                  ${pkgs.docker}/bin/docker run \
                    -d --rm \
                    --name ${localDb.dbName} \
                    -e POSTGRES_DB=${localDb.dbName} \
                    -e POSTGRES_USER=${localDb.username} \
                    -e POSTGRES_PASSWORD=${localDb.password} \
                    -p ${toString localDb.port}:5432 postgres:16
                '';

                dbDown = pkgs.writeShellScriptBin "dbDown" ''
                  ${pkgs.docker}/bin/docker stop ${localDb.dbName}
                '';
              };
          in
          pkgs.mkShell {
            buildInputs =
              (with pkgs; [
                # base
                git
                less
                ncurses
                pkg-config
                which
                # rust
                rust
              ])
              ++ (builtins.attrValues scripts);

            shellHook = ''
              export ROOT_DIR=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
              ${pkgs.cowsay}/bin/cowsay "Working on project root directory: ${rootDir}"
              cd ${rootDir}
            '';
          };
      }
    );
}

{
  description = "A devShell example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default =
          let
            rootDir = "$ROOT_DIR";
            scripts = {
              format = pkgs.writeShellScriptBin "format" ''
                cd ${rootDir}
                find ${rootDir} | grep '\.nix$' | xargs -I _ bash -c "echo running nixfmt on _ && ${pkgs.nixfmt-rfc-style}/bin/nixfmt _"
                find ${rootDir} | grep '\.toml$' | xargs -I _ bash -c "echo running taplo on _ && ${pkgs.taplo}/bin/taplo format _"
                find ${rootDir} | grep '\.py$' | xargs -I _ bash -c "echo running black on _ && ${pkgs.black}/bin/black _"
              '';
            };
          in
          pkgs.mkShell {
            buildInputs =
              (with pkgs; [
                # base
                git
                less
                which
                # python
                black
                (python312.withPackages (
                  p: with p; [
                    python-lsp-server
                    python-lsp-black
                    requests
                  ]
                ))
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

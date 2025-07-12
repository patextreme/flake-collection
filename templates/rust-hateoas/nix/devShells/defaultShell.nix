{
  pkgs,
  mkShell,
  writeShellApplication,
  rustUtils,
}:

let
  rust = rustUtils.rust;
  rootDir = "$ROOT_DIR";
  scripts = {
    format = writeShellApplication {
      name = "format";
      runtimeInputs = with pkgs; [
        taplo
        nixfmt-rfc-style
      ];
      text = ''
        cd "${rootDir}"
        find "${rootDir}" | grep '\.nix$' | xargs -I _ bash -c "echo running nixfmt on _ && nixfmt _"
        find "${rootDir}" | grep '\.toml$' | xargs -I _ bash -c "echo running taplo on _ && taplo format _"

        cargo fmt

        cd "${rootDir}/migrations"
        sqlfluff fix .
        sqlfluff lint .
      '';
    };

    build = writeShellApplication {
      name = "build";
      text = ''
        cd "${rootDir}"
        cargo build
      '';
    };
  };
in
mkShell {
  buildInputs =
    (with pkgs; [
      # base
      cowsay
      git
      less
      ncurses
      pkg-config
      which
      # rust
      cargo-edit
      cargo-udeps
      rust
      # db
      sqlfluff
      sqlx-cli
    ])
    ++ (builtins.attrValues scripts);

  shellHook = ''
    export ROOT_DIR=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
    cowsay "Working on project root directory: ${rootDir}"
    cd ${rootDir}
  '';
}

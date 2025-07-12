{ pkgs, rust-overlay }:

let
  nightlyVersion = "2025-07-01";
in
{
  rustMinimal = pkgs.rust-bin.nightly.${nightlyVersion}.latest.minimal;
  rust = pkgs.rust-bin.nightly.${nightlyVersion}.default.override {
    extensions = [
      "rust-src"
      "rust-analyzer"
    ];
    targets = [ ];
  };
}

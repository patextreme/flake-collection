{ pkgs }:
let
  rust = pkgs.rust-bin.nightly."2024-09-22".default.override {
    extensions = [ ];
    targets = [ ];
  };
  rustPlatform = pkgs.makeRustPlatform {
    cargo = rust;
    rustc = rust;
  };
in
{
  loco-cli = rustPlatform.buildRustPackage rec {
    pname = "loco-cli";
    version = "0.2.9";
    src = pkgs.fetchCrate {
      inherit pname version;
      hash = "sha256-AhL+k5XEf8m1pyOECTlPwALUG/ELJeACfV2kulxlzaA=";
    };
    cargoHash = "sha256-BtunTti1cPbG1Qiv39tLdbXHM413UzsCckyqL5CJEUA=";
    doCheck = false;
  };

  sea-orm-cli = rustPlatform.buildRustPackage rec {
    pname = "sea-orm-cli";
    version = "1.0.1";
    src = pkgs.fetchCrate {
      inherit pname version;
      hash = "sha256-b1Nlt3vsLDajTiIW9Vn51Tv9gXja8/ZZBD62iZjh3KY=";
    };
    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs =
      with pkgs;
      [ openssl ]
      ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.darwin.apple_sdk.frameworks.SystemConfiguration ];
    cargoHash = "sha256-ZGM+Y67ycBiukgEBUq+WiA1OUCGahya591gM6CGwzMQ=";
    doCheck = false;
  };
}

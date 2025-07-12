{ pkgs }:

{
  default = pkgs.callPackage ./defaultShell.nix { };
}

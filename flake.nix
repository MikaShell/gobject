{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  inputs.nix-wpe-webkit.url = "github:eval-exec/nix-wpe-webkit";

  outputs = {
    nixpkgs,
    nix-wpe-webkit,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
    ];
  in {
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        wpewebkit = nix-wpe-webkit.packages.${system}.wpewebkit;
      in {
        default = pkgs.callPackage ./devshell.nix {inherit wpewebkit;};
      }
    );
  };
}

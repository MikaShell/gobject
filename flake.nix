{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  inputs.nix-wpe-webkit.url = "github:eval-exec/nix-wpe-webkit";
  inputs.zig-overlay.url = "github:mitchellh/zig-overlay";
  inputs.zig-overlay.inputs.nixpkgs.follows = "nixpkgs";
  outputs = {
    nixpkgs,
    nix-wpe-webkit,
    zig-overlay,
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
        zig = zig-overlay.packages.${system}.master;
      in {
        default = pkgs.callPackage ./devshell.nix {inherit wpewebkit zig;};
      }
    );
  };
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [
      "https://cache.garnix.io"
      "https://nix-wpe-webkit.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "nix-wpe-webkit.cachix.org-1:ItCjHkz1Y5QcwqI9cTGNWHzcox4EqcXqKvOygxpwYHE="
    ];
  };
}

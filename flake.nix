{
  description = "A Pet Project for Nix";


  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    gomod2nix.url = "github:nix-community/gomod2nix";
    gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
    gomod2nix.inputs.flake-utils.follows = "flake-utils";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, gomod2nix, utils }:
    let
      pkgs = import <nixpkgs> {};
      localOverlay =  import ./nix/default.nix;
      # The current default sdk for macOS fails to compile go projects, so we use a newer one for now.
      # This has no effect on other platforms.

      pkgsForSystem = system: import nixpkgs {
        # if you have additional overlays, you may add them here
        overlays = [
            localOverlay # this should expose devShell
        ];
        inherit system;
      };
    in utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system: rec {
        legacyPackages = pkgsForSystem system;
        packages = {
            inherit (legacyPackages) devShell template;
            default = pkgs.callPackage ./. {
                inherit (gomod2nix.legacyPackages.${system}) buildGoApplication;
            };
        };
        checks = { inherit (legacyPackages) template; };
        devShells.default = {
            inherit legacyPackages;
            default = pkgs.callPackage ./. {
                inherit (gomod2nix.legacyPackages.${system}) mkGoEnv gomod2nix;
            };
        };
    });
}

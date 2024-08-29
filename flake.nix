{
  description = "A Pet Project for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.gomod2nix.url = "github:nix-community/gomod2nix";
  inputs.gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.gomod2nix.inputs.flake-utils.follows = "flake-utils";

  outputs = { self, nixpkgs, flake-utils, gomod2nix }:
    (flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # The current default sdk for macOS fails to compile go projects, so we use a newer one for now.
          # This has no effect on other platforms.
          callPackage = pkgs.darwin.apple_sdk_11_0.callPackage or pkgs.callPackage;
          serviceName = "echo";
          pwd = builtins.getEnv "PWD";
          version = builtins.hashString "sha256" pwd;
          path = "";
        in
        rec {
          environment.sessionVariables = rec {
            XDG_CACHE_HOME  = "$HOME/.cache";
            XDG_CONFIG_HOME = "$HOME/.config";
            XDG_DATA_HOME   = "$HOME/.local/share";
            XDG_STATE_HOME  = "$HOME/.local/state";

            # Not officially in the specification
            XDG_BIN_HOME    = "$HOME/.local/bin";
            PATH = [
              "${XDG_BIN_HOME}"
            ];
          };

          packages.build = callPackage ./services/echo {
            inherit (gomod2nix.legacyPackages.${system}) buildGoApplication;
            version = version;
            serviceName = serviceName;
          };
          packages.contain = pkgs.dockerTools.buildImage {
            name = "echo";
            tag = packages.build.version;
            created = "now";
            copyToRoot = packages.build;
            config.Cmd = [ "${packages.build}/bin/main" ];
          };
          devShells.default = callPackage ./shell.nix {
            inherit (gomod2nix.legacyPackages.${system}) mkGoEnv gomod2nix;
          };
        })
    );
}

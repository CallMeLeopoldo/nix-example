final: prev: {
#  template = prev.callPackage ./template.nix { };

  devShell = prev.callPackage ./shell.nix { };
}
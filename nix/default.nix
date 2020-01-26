let
  sources = import ./sources.nix;

  pkgs = import sources.nixpkgs {
    config = {};
    overlays = [
      (import sources.hugo-book)
    ];
  };
in
pkgs

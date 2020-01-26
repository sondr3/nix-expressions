{ pkgs ? import <nixpkgs> {}
, ci ? import ./ci.nix {}
, sources ? import ./nix/sources.nix {} }:

with builtins;

let
  pkgsMeta = map (pkg: (parseDrvName pkg.name) // { description = pkg.meta.description; } ) ci.buildPkgs;
  pkgsJSON = pkgs.writeText "pkgsJson" (toJSON pkgsMeta);
in
{
  website = pkgs.stdenv.mkDerivation {
    name = "site";
    version = "0.1";
    src = ./docs;
    buildInputs = [ pkgs.hugo pkgs.caddy ];

    buildPhase = ''
      cp -r ${sources.hugo-book} themes/book
      cp ${pkgsJSON} pkgs.json
    '';

    installPhase = ''
      hugo --minify --theme book -d $out
    '';

    shellHook = ''
      caddy -host 0.0.0.0 -port 8000 -root $out && exit
    '';
  };
}

{ pkgs ? import <nixpkgs> {}
, ci ? import ./ci.nix {}
, sources ? import ./nix/sources.nix {} }:

with builtins;

let
  pkgsMeta = map (pkg: (parseDrvName pkg.name) // { description = pkg.meta.description; url = pkg.meta.homepage; } ) ci.buildPkgs;
  pkgsJSON = pkgs.writeText "pkgsJson" (toJSON pkgsMeta);
in
{
  website = pkgs.stdenv.mkDerivation {
    name = "site";
    version = "0.1";
    src = ./site;
    buildInputs = [ pkgs.hugo pkgs.caddy ];

    buildPhase = ''
      cp -r ${sources.hugo-book} themes/book
      cp ${pkgsJSON} data/pkgs.json
    '';

    installPhase = ''
      hugo --minify -d $out
      # hacks because Hugo hates relative URLs
      mkdir $out/nix
      cp $out/*.css $out/nix/
    '';

    shellHook = ''
      caddy -host 0.0.0.0 -port 8000 -root $out && exit
    '';
  };
}

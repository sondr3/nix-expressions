{ pkgs ? import <nixpkgs> { }, stdenv
, ghcWithPackages ? pkgs.haskellPackages.ghcWithPackages, makeWrapper
, packages ? (x: [ ]) }:

let xmobarEnv = ghcWithPackages (self: [ self.xmobar ] ++ packages self);
in stdenv.mkDerivation {
  name = "xmobar-with-packages-${xmobarEnv.version}";

  nativeBuildInputs = [ makeWrapper ];

  buildCommand = ''
    mkdir -p $out/bin
    makeWrapper ${xmobarEnv}/bin/xmobar $out/bin/xmobar \
      --set NIX_GHC "${xmobarEnv}/bin/ghc"
  '';
}

{ stdenv, fetchFromGitHub, rustPlatform, pkgconfig }:

let
  moz_overlay = import sources.nixpkgs-mozilla;
  sources = import ../../nix/sources.nix;
  pkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
  myBuildRustPackage = pkgs.makeRustPlatform {
    cargo = pkgs.latest.rustChannels.stable.rust;
    rustc = pkgs.latest.rustChannels.stable.rust;
  };
in myBuildRustPackage.buildRustPackage rec {
  pname = "rust-analyzer";
  version = "2020-02-11";

  src = fetchFromGitHub {
    owner = "rust-analyzer";
    repo = "rust-analyzer";
    rev = "${version}";
    sha256 = "0xr8iz7cmmj745ymbjig66pxvl8pi93fhigm70dp2brb685ibaay";
  };

  cargoSha256 = "0ha71kv54aijaadcakpb4hr69dlc4wfc8i7m8fl6jgp631bn2rla";
  nativeBuildInputs = [ pkgconfig rustPlatform.rustcSrc ];
  doCheck = true;

  preBuild = "pushd crates/ra_lsp_server";
  postBuild = "popd";

  # Some tests will invoke rustup to install components.
  patches = [ ./no-invoke-rustup.patch ];

  preCheck = ''
    export RUST_SRC_PATH=${rustPlatform.rustcSrc}
    echo $RUST_SRC_PATH
  '';

  meta = with stdenv.lib; {
    description =
      "An experimental modular compiler frontend for the Rust language";
    homepage = "https://github.com/rust-analyzer/rust-analyzer";
    license = with licenses; [ mit asl20 ];
    platforms = platforms.all;
  };
}

{ stdenv
, lib
, rustPlatform
, irmaseal-src
}:
let
  version = "0.1.2";
in
rustPlatform.buildRustPackage {
  pname = "irmaseal-pkg";
  inherit version;

  buildInputs = [ ];

  src = "${irmaseal-src}/irmaseal-pkg";

  cargoSha256 = "y+fL4ERkEcuIAgNBFHNrWBBwoZ4VfGpqpHFqEJDymkg=";

}

{ stdenv
, lib
, rustPlatform
, irmaseal-src
}:
let
  version = "0.1.4";
in
rustPlatform.buildRustPackage {
  pname = "irmaseal-cli";
  inherit version;

  buildInputs = [ ];

  src = "${irmaseal-src}/irmaseal-cli";

  cargoSha256 = "ieIxRUDgZ9Lyg5pNtIO/2zXYS+GfwWRZ5ARiSbk9X8E=";

}

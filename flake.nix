{
  description = "IRMAseal - identity based encryption service";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";

    irmaseal-src = {
      url = "github:Wassasin/irmaseal";
      flake = false;
    };

  };


  outputs =
    { self
    , nixpkgs
    , irmaseal-src
    , ...
    }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        }
      );

    in
    {

      overlay = final: prev: rec {

        irmaseal-cli = with final; callPackage ./pkgs/irmaseal-cli.nix {
          inherit irmaseal-src;
        };

        irmaseal-pkg = with final; callPackage ./pkgs/irmaseal-pkg.nix {
          inherit irmaseal-src;
        };

      };

      nixosModules.irmaseal-pkg = {
        imports = [ ./modules/irmaseal-pkg-server.nix ];
        nixpkgs.overlays = [ self.overlay ];
      };

      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system})
          irmaseal-cli
          irmaseal-pkg;
      });


      defaultPackage =
        forAllSystems (system: self.packages.${system}.irmaseal-cli);

    };

}

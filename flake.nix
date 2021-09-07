{
  description = "IRMAseal - identity based encryption service";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";

    irmaseal-src = {
      url = "github:Wassasin/irmaseal";
      flake = false;
    };

    nixos-shell.url = "github:mic92/nixos-shell";

  };


  outputs =
    { self
    , nixpkgs
    , irmaseal-src
    , nixos-shell
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

      apps = forAllSystems (system: {
        generate-keys = {
          type = "app";
          program = builtins.toString (nixpkgsFor."${system}".writeScript "generate-keys" ''
            ${self.packages."${system}".irmaseal-pkg}/bin/irmaseal-pkg generate "$@"
          '');
        };

        nixos-shell = {
          type = "app";
          program = builtins.toString (nixpkgs.legacyPackages."${system}".writeScript "nixos-shell" ''
            ${nixos-shell.defaultPackage."${system}"}/bin/nixos-shell \
              -I nixpkgs=${nixpkgs} \
              ./modules/test-module.nix
          '');
        };
      });


      defaultPackage =
        forAllSystems (system: self.packages."${system}".irmaseal-pkg);


      checks = forAllSystems (system: {
        inherit (self.packages.${system}) irmaseal-pkg;

        # A VM test of the NixOS module.
        vmTest =
          with import (nixpkgs + "/nixos/lib/testing-python.nix") {
            inherit system;
          };

          makeTest {
            nodes = {
              client = { ... }: {
                imports = [ self.nixosModules.irmaseal-pkg ];
                services.irmaseal-pkg.enable = true;
              };
            };

            testScript =
              ''
                start_all()
                client.wait_for_open_port("8087")
              '';
          };
      });

    };

}

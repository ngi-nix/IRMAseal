{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.irmaseal-pkg;
in
{

  options.services.irmaseal-pkg = {

    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, NixOS will periodically update the database of
        files used by the locate command.
      '';
    };

    package = mkOption {
      type = types.path;
      default = pkgs.irmaseal-pkg;
      description = "The IRMAseal PKG package to use";
    };

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = ''
        Host to bind this service to
      '';
    };

    irma = mkOption {
      type = types.str;
      default = "https://irma-noauth.demo.sarif.nl";
      description = ''
        URL of the IRMA go server to use for authentication
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8087;
      description = ''
        TCP port to bind this service to
      '';
    };

    publicKeyPath = mkOption {
      type = types.path;
      default = ./pkg.pub;
      description = ''
        Path to the public key
      '';
    };

    secretKeyPath = mkOption {
      type = types.path;
      default = ./pkg.sec;
      description = ''
        Path to the private key
      '';
    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.update-locatedb = {
      description = "IRMAseal PKG HTTP server";
      wantedBy = [ "multi-user.target" ];
      serviceConfig =
        {
          ExecStart = ''
            ${cfg.package}/bin/iramseal-pkg server \
              --host '${cfg.host}' \
              --irma '${cfg.irma}' \
              --port ${toString cfg.port} \
              --public '${cfg.publicKeyPath}' \
              --secret '${cfg.secretKeyPath}'
          '';

          Restart = "always";
        };
    };

  };

}

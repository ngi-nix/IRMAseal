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
        This option enables the IRMAseal-PKG server.
      '';
    };

    package = mkOption {
      type = types.path;
      default = pkgs.irmaseal-pkg;
      description = "The IRMAseal-PKG package to use";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
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

    keyDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to the directory containing private + public key.
        If keys $keyDir/pkg.pub and $keyDir/pkg.sec do not exist,
        they are generated on first start.
        Generate keys by executing: `nix run .#generate-keys`
      '';
    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.irmaseal-pkg = {
      description = "IRMAseal PKG HTTP server";
      wantedBy = [ "multi-user.target" ];
      preStart = lib.optionalString (cfg.keyDir == null) ''
        ${pkgs.irmaseal-pkg}/bin/irmaseal-pkg generate \
          -P "/var/lib/irmaseal-pkg/pkg.pub" \
          -S "/var/lib/irmaseal-pkg/pkg.sec"
      '';
      serviceConfig = {
        ExecStart = 
        let 
          keyDir = if (cfg.keyDir == null) then "/var/lib/irmaseal-pkg" else cfg.keyDir;
        in ''
          ${cfg.package}/bin/irmaseal-pkg server \
            --host '${cfg.host}' \
            --irma '${cfg.irma}' \
            --port ${toString cfg.port} \
            --public "${keyDir}/pkg.pub" \
            --secret "${keyDir}/pkg.sec"
        '';
        Restart = "always";
        DynamicUser = true;
        PrivateTmp = true;
        StateDirectory = "irmaseal-pkg";
        ReadOnlyPaths = mkIf (cfg.keyDir != null) "${cfg.keyDir}";
      };
    };

  };

}

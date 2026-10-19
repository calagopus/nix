{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.calagopus-wings;

  format = pkgs.formats.yaml {};
  generatedConfig = format.generate "config.yml" cfg.config;
in {
  options.services.calagopus-wings = {
    enable = lib.mkEnableOption "Calagopus Wings";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.wings;
      description = "The wings package to use. Override with pkgs.wings-nightly for nightly builds.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file containing secret environment variables, e.g.
        CALAGOPUS_TOKEN (and optionally CALAGOPUS_TOKEN_ID / CALAGOPUS_UUID).
        Wings maps CALAGOPUS_<KEY> environment variables onto the matching
        config.yml field, so secrets never need to be written into `config`
        or the Nix store.
      '';
    };

    config = lib.mkOption {
      type = lib.types.nullOr format.type;
      default = null;
      description = ''
        Wings configuration (config.yml). Do not set `token` here -- it
        would be stored world-readable in the Nix store. Use
        `environmentFile` with CALAGOPUS_TOKEN instead.
        See <https://calagopus.com/docs/wings/configuration>.
      '';
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a complete config.yml, bypassing `config`.";
    };
  };

  config = lib.mkIf cfg.enable {
    warnings =
      lib.optional (cfg.config != null && cfg.config ? token) ''
        services.calagopus-wings: Setting config.token embeds the secret in
        the Nix store. Use environmentFile with CALAGOPUS_TOKEN instead.
      ''
      ++ lib.optional (!config.virtualisation.docker.enable && !config.virtualisation.podman.enable) ''
        services.calagopus-wings: Neither Docker nor Podman is enabled.
        Wings requires a container runtime to function.
      '';

    assertions = [
      {
        assertion = cfg.config != null || cfg.configFile != null;
        message = "services.calagopus-wings: one of `config` or `configFile` must be set.";
      }
    ];

    users.users.calagopus-wings = {
      isSystemUser = true;
      group = "calagopus-wings";
      extraGroups = lib.optional config.virtualisation.docker.enable "docker";
    };
    users.groups.calagopus-wings = {};

    systemd.services.calagopus-wings = {
      description = "Calagopus Wings";
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = "calagopus-wings";
        Group = "calagopus-wings";
        StateDirectory = "calagopus-wings";
        LogsDirectory = "calagopus-wings";
        WorkingDirectory = "/var/lib/calagopus-wings";
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${lib.getExe cfg.package} --config ${
          if cfg.configFile != null
          then cfg.configFile
          else generatedConfig
        }";
        Restart = "on-failure";
        RestartSec = "5s";

        # Hardening needs more testing
        NoNewPrivileges = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        RestrictRealtime = true;
        LockPersonality = true;
      };
    };
  };
}

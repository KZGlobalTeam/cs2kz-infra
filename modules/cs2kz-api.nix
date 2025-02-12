{ lib, pkgs, inputs, cs2kz-api, sshKeys, ... }:

{
  imports = [ ./nginx.nix ];
  services = {
    mysql = {
      enable = true;
      package = lib.mkForce pkgs.mariadb;
      ensureDatabases = [ "cs2kz" ];
      ensureUsers = [{
        name = "schnose";
        ensurePermissions = {
          "cs2kz.*" = "ALL PRIVILEGES"; # TODO: more granular permissions
        };
      }];
      initialDatabases = [{
        name = "cs2kz";
        schema = "${inputs.cs2kz-api}/crates/cs2kz/migrations/0001_initial.up.sql";
      }];
    };
    mysqlBackup = {
      enable = true;
      calendar = "02:30:00";
      databases = [ "cs2kz" ];
    };
  };
  systemd.user.services.cs2kz-api = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionUser = "schnose";
    environment = {
      RUST_LOG = "cs2kz=trace,steam_openid=debug,warn";
      KZ_API_ENVIRONMENT = "production";
    };
    script = ''
      ${cs2kz-api}/bin/cs2kz-api \
        --config "/etc/cs2kz-api.toml" \
        --depot-downloader-path "${pkgs.depotdownloader}/bin/DepotDownloader"
    '';
  };
  users = {
    users.schnose = {
      isNormalUser = true;
      linger = true;
      useDefaultShell = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = sshKeys;
    };
  };
}

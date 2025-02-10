{ lib, pkgs, ... }:

let
  mkVirtualHost = { locations ? { } }: {
    forceSSL = true;
    enableACME = true;
    locations = lib.attrsets.mapAttrs
      (_: cfg: cfg // {
        extraConfig = ''
          if ($cloudflare_ip != 1) {
            return 403;
          }

          ${cfg.extraConfig or ""}
        '';
      })
      locations;
  };
in

{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "api.cs2kz.org" = mkVirtualHost {
        locations."/" = {
          proxyPass = "http://[::1]:42069";
          proxyWebsockets = true;
          extraConfig = ''
            # required when the server wants to use HTTP Authentication
            proxy_pass_header Authorization;
          '';
        };
      };
      "forum.cs2kz.org" = mkVirtualHost {
        # TODO
      };
    };
    commonHttpConfig =
      let
        realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
        allowFromList = lib.strings.concatMapStringsSep "\n" (x: "${x} 1;");
        fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
        cfipv4 = fileToList (pkgs.fetchurl {
          url = "https://www.cloudflare.com/ips-v4";
          sha256 = "0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
        });
        cfipv6 = fileToList (pkgs.fetchurl {
          url = "https://www.cloudflare.com/ips-v6";
          sha256 = "1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
        });
      in
      ''
        geo $realip_remote_addr $cloudflare_ip {
          default          0;
          ${allowFromList cfipv4}
          ${allowFromList cfipv6}
        }

        # Proxy CF-ConnectingIP header
        ${realIpsFromList cfipv4}
        ${realIpsFromList cfipv6}
        real_ip_header CF-Connecting-IP;
      '';
  };
}

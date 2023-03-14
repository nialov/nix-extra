{ lib }:
let
  cacheConfig = ''
    proxy_cache nginx-proxy-cache;
    proxy_cache_revalidate on;
    proxy_cache_min_uses 3;
    proxy_cache_use_stale error timeout updating http_500 http_502
                          http_503 http_504;
    proxy_cache_background_update on;
    proxy_cache_lock on;
  '';
  restrictIPsConfig = ''
    allow 100.0.0.0/8;
    allow 192.168.50.0/24;
    deny all;
  '';
  mkHost = { proxyPass, proxyWebsockets ? false, enableCache ? false
    , extraExtraConfig ? "", restrictIPs ? true }:
    let
      extraConfig = (lib.optionalString enableCache cacheConfig)
        + extraExtraConfig;

    in {
      useACMEHost = "novaskai.xyz";
      forceSSL = true;
      locations."/" = { inherit proxyPass extraConfig proxyWebsockets; };
      extraConfig = lib.optionalString restrictIPs restrictIPsConfig;
    };
  mkHostWithCache = proxyPass:
    mkHost {
      inherit proxyPass;
      enableCache = true;
    };
  # Enable websocket support with extraConfig
  mkHostWebsocket = proxyPass:
    mkHost {
      inherit proxyPass;
      proxyWebsockets = true;
    };
  # mkHostPlain = proxyPass: mkHost { inherit proxyPass; };
  # mkHostWebsocketAndCache = proxyPass:
  #   mkHost {
  #     inherit proxyPass;
  #     proxyWebsockets = true;
  #     enableCache = true;
  #   };
  mkJellyfinHost = proxyPass:
    lib.recursiveUpdate (mkHostWithCache proxyPass) {
      locations."/socket/".proxyWebsockets = true;
    };

in { inherit mkHostWithCache mkJellyfinHost mkHostWebsocket; }

{
  name = "library";

  nodes.machine = { pkgs, ... }:

    {
      # Setup nginx
      services.nginx.virtualHosts = {
        "cache.domain.org" =
          pkgs.library.nginx.mkHostWithCache "http://localhost:1001";
        "websocket.domain.org" =
          pkgs.library.nginx.mkHostWebsocket "http://localhost:1002";
        "jellyfin.domain.org" =
          pkgs.library.nginx.mkJellyfinHost "http://localhost:1003";
      };

    };

  testScript = ''
    machine.start()
  '';
}

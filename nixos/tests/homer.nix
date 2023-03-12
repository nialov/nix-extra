{
  name = "homer";

  nodes.machine = { pkgs, ... }:

    {

      services.homer = let
        images = {
          "router.png" = pkgs.fetchurl {
            url = "https://i.imgur.com/pHhwGQj.png";
            sha256 = "sha256-CE5VP43S+Rj+m0gBuNszWi6phpHCq7GE9WHa8qODRlQ=";
          };
        };
        defaultSettings = {
          footer = ''
            <p>Created with <span class="has-text-danger">❤️</span> with <a href="https://bulma.io/">bulma</a>, <a href="https://vuejs.org/">vuejs</a> & <a href="https://fontawesome.com/">font awesome</a> // Fork me on <a href="https://github.com/bastienwirtz/homer"><i class="fab fa-github-alt"></i></a></p>'';
          header = true;
          logo = "logo.png";
          message = {
            content =
              "My dashboard. <br /> Find more information on <a href='https://github.com/bastienwirtz/homer'>github.com/bastienwirtz/homer</a>";
            icon = "fa fa-grin";
            style = "is-dark";
            title = "Demo !";
          };
          subtitle = "user";
          title = "Dashboard";
        };
        defaultServices = [{
          icon = "fas fa-cloud";
          items = [{
            logo = "assets/tools/router.png";
            name = "Router";
            subtitle = "Router website";
            tag = "app";
            url = "https://router.domain.org";
          }];
          name = "Management";
        }];
      in {

        enable = true;
        # configFile = ../modules/homer/config.yml;
        port = 6781;
        settings = defaultSettings;
        services = defaultServices;
        inherit images;

      };

    };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    machine.wait_for_open_port(6781)

    assert "Homer" in machine.succeed("curl -sSf http://localhost:6781")
  '';
}

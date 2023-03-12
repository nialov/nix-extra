{
  name = "flipperzero";

  nodes.machine = _:

    {

      users.users.nialov = { isNormalUser = true; };
      hardware.flipperzero = {
        enable = true;
        enableu2f = true;
        enableu2fLogin = true;
        enableu2fSudo = true;
        enableForUser = "nialov";
        u2fKeys = [ "some-key-string-public" ];
      };

    };

  testScript = ''
    machine.succeed("which qFlipper-cli")
  '';
}

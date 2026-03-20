{
  inputs,
  lib,
  rustPlatform,
  # fetchFromGitHub,
  # nix-update-script,
  versionCheckHook,
}:

# rustPlatform.buildRustPackage (finalAttrs: {
rustPlatform.buildRustPackage {
  pname = "harper";
  version = "0.1.0";

  src = inputs.harper-src;

  buildAndTestSubdir = "harper-cli";

  cargoHash = "sha256-79wUwINGkhHSmb+0Mq+x+evZNLfhNtWoRgoJHhIlw90=";

  # passthru.updateScript = nix-update-script { };

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;

  meta = {
    description = "Harper command-line interface";
    homepage = "https://github.com/Automattic/harper";
    # changelog = "https://github.com/Automattic/harper/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      nialov
    ];
    mainProgram = "harper-cli";
  };
}

{ lib }: {
  mkOnFailureSetups = serviceNames:
    lib.genAttrs serviceNames
    (_: { onFailure = [ "notify-apprise@%n.service" ]; });
}

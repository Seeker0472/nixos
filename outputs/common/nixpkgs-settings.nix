{ inputs, ... }:
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlays.default
      (final: prev: {
        # workaround for https://github.com/NixOS/nixpkgs/issues/471331
        xow_dongle-firmware = prev.runCommand "dummy-xow-firmware" { } ''
          mkdir -p $out/lib/firmware

          echo "dummy" > $out/lib/firmware/xow_placeholder.bin
          echo "This is a dummy firmware to bypass download errors" > $out/README
        '';
        xone-dongle-firmware = prev.runCommand "dummy-xone-firmware" { } ''
          mkdir -p $out/lib/firmware

          echo "dummy" > $out/lib/firmware/xow_placeholder.bin
          echo "This is a dummy firmware to bypass download errors" > $out/README
        '';

      })
    ];
  };

}

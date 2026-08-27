{ inputs, system }:
import inputs.nixpkgs {
  inherit system;
  config.allowUnfree = true;
}

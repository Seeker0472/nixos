{
  config,
  osConfig,
  lib,
  ...
}:
let
  persistDir = lib.attrByPath [
    "machine"
    "btrfs"
    "impermanence"
    "persistdir"
  ] null osConfig;
in
{
  # FIXME:add An Option
  options.machine.home.zen.enable = lib.mkEnableOption "Zen Browser";
  config = lib.mkMerge [
    (lib.mkIf config.machine.home.zen.enable {
      programs.zen-browser.enable = true;
    })
    (lib.mkIf config.machine.home.zen.enable (
      if persistDir != null then
        {
          home.persistence."${persistDir}".directories = [
            # ".zen"
            ".config/zen"
          ];
        }
      else
        { }
    ))
  ];
}

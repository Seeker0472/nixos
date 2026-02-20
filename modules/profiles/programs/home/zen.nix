{
  config,
  osConfig,
  lib,
  ...
}:
{
  # FIXME:add An Option
  options.seeker.home.zen.enable = lib.mkEnableOption "Zen Browser";
  config = lib.mkMerge [
    (lib.mkIf config.seeker.home.zen.enable {
      programs.zen-browser.enable = true;
      home.persistence."${osConfig.seeker.btrfs.impermanence.persistdir}".directories = [
        # ".zen"
        ".config/zen"
      ];
    })
  ];
}

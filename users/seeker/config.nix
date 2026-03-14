{
  config,
  lib,
  ...
}:
{
  options.seeker.gui.enable =
    lib.mkEnableOption "GUI applications and desktop integration for seeker"
    // {
      default = true;
    };

  config = {
    seeker.gui.enable = lib.mkDefault true;

    machine.home = lib.mkIf config.seeker.gui.enable {
      qq.enable = lib.mkDefault true;
      # wechat.enable = true;
      zed.enable = lib.mkDefault true;
      zotero.enable = lib.mkDefault true;
      neteaseMusic.enable = lib.mkDefault true;
      obsidian.enable = lib.mkDefault true;
      vscode.enable = lib.mkDefault true;
      zen.enable = lib.mkDefault true;
    };

    programs = {
      fish.enable = lib.mkDefault true;
      kitty.enable = lib.mkDefault config.seeker.gui.enable;
      yazi.enable = lib.mkDefault true;
      direnv.enable = lib.mkDefault true;
    };
  };
}

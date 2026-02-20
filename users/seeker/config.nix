{ pkgs, ... }:
{
  config = {
    seeker.home = {
      qq.enable = true;
      wechat.enable = true;
      zed.enable = true;
      zotero.enable = true;
      neteaseMusic.enable = true;
      obsidian.enable = true;
      vscode.enable = true;
      zen.enable = true;

    };
    programs = {
      fish.enable = true;
      kitty.enable = true;
      yazi.enable = true;
      direnv.enable = true;
    };
  };
}

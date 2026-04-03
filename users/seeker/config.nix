{
  config,
  lib,
  osConfig,
  ...
}:
let
  alohaFeature = lib.attrByPath [
    "machine"
    "features"
    "launcher"
    "aloha"
    "enable"
  ] false osConfig;
  impermanenceEnabled = lib.attrByPath [
    "machine"
    "impermanence"
    "enable"
  ] false osConfig;
in
{
  options.seeker.gui.enable =
    lib.mkEnableOption "GUI applications and desktop integration for seeker"
    // {
      default = true;
    };

  config = {
    seeker.gui.enable = lib.mkDefault true;

    homeProfiles = {
      ai = {
        claude.enable = lib.mkDefault false;
        codex.enable = lib.mkDefault impermanenceEnabled;
        gemini.enable = lib.mkDefault true;
      };

      launchers.aloha.enable = lib.mkDefault alohaFeature;

      cli = {
        bash.enable = lib.mkDefault true;
        direnv.enable = lib.mkDefault true;
        fish.enable = lib.mkDefault true;
        tmux.enable = lib.mkDefault true;
        yazi.enable = lib.mkDefault true;
      };

      terminals.kitty.enable = lib.mkDefault config.seeker.gui.enable;

      packages = {
        ai.enable = lib.mkDefault (
          config.homeProfiles.ai.claude.enable
          || config.homeProfiles.ai.codex.enable
          || config.homeProfiles.ai.gemini.enable
        );
        base.enable = lib.mkDefault true;
        dev.enable = lib.mkDefault true;
        media.enable = lib.mkDefault config.seeker.gui.enable;
        office.enable = lib.mkDefault config.seeker.gui.enable;
      };

      apps = lib.mkIf config.seeker.gui.enable {
        qq.enable = lib.mkDefault true;
        zed.enable = lib.mkDefault true;
        zotero.enable = lib.mkDefault true;
        neteaseMusic.enable = lib.mkDefault true;
        obsidian.enable = lib.mkDefault true;
        vscode.enable = lib.mkDefault true;
        zen.enable = lib.mkDefault true;
      };
    };
  };
}

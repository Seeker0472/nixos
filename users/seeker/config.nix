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
  persistDir = lib.attrByPath [
    "machine"
    "btrfs"
    "impermanence"
    "persistdir"
  ] null osConfig;
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
        codex = {
          enable = lib.mkDefault impermanenceEnabled;
          model = lib.mkDefault "gpt-5.4";
          reviewModel = lib.mkDefault "gpt-5.4";
          enableHooks = lib.mkDefault true;
          settings = lib.mkDefault {
            model_provider = "OpenAI";
            model_reasoning_effort = "high";
            disable_response_storage = true;
            network_access = "enabled";
            windows_wsl_setup_acknowledged = true;
            model_context_window = 1000000;
            model_auto_compact_token_limit = 900000;
            model_providers.OpenAI = {
              name = "OpenAI";
              base_url = "https://rust.cat";
              wire_api = "responses";
              requires_openai_auth = true;
            };
          };
        };
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

    home.persistence = lib.mkIf (impermanenceEnabled && persistDir != null) {
      "${persistDir}" = {
        directories = [
          ".codex/skills/ask-codex"
          ".codex/skills/humanize"
          ".codex/skills/humanize-gen-plan"
          ".codex/skills/humanize-refine-plan"
          ".codex/skills/humanize-rlcr"
          ".config/humanize"
        ];
        files = [
          ".codex/hooks.json"
          ".local/bin/bitlesson-selector"
        ];
      };
    };
  };
}

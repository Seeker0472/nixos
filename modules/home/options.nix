{ lib, ... }:
{
  options.homeProfiles = {
    ai = {
      claude.enable = lib.mkEnableOption "Claude Code";
      codex.enable = lib.mkEnableOption "Codex CLI";
      gemini.enable = lib.mkEnableOption "Gemini CLI";
    };

    launchers.aloha = {
      enable = lib.mkEnableOption "Aloha launcher";
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Optional package override for the Aloha launcher.";
      };
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Repository-owned wrapper settings that are merged into programs.aloha.";
      };
    };

    cli = {
      bash.enable = lib.mkEnableOption "Bash shell integration";
      direnv.enable = lib.mkEnableOption "Direnv";
      fish.enable = lib.mkEnableOption "Fish shell";
      tmux.enable = lib.mkEnableOption "tmux";
      yazi.enable = lib.mkEnableOption "Yazi";
    };

    terminals.kitty.enable = lib.mkEnableOption "Kitty terminal";
    terminals.command = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Resolved terminal command for launcher integrations.";
    };

    packages = {
      ai.enable = lib.mkEnableOption "AI-related support packages";
      base.enable = lib.mkEnableOption "Base CLI package bundle";
      dev.enable = lib.mkEnableOption "Development package bundle";
      media.enable = lib.mkEnableOption "Media and graphics package bundle";
      office.enable = lib.mkEnableOption "Office and document package bundle";
    };
  };
}

{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  cfg = config.homeProfiles.ai.claude;
  deploySecrets = lib.attrByPath [
    "machine"
    "secrets"
    "deploy"
  ] true osConfig;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.claude-code = {
        enable = true;
        settings = { };
      };

      home.activation.initClaudeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        CLAUDE_CONF="${config.home.homeDirectory}/.claude.json"

        if [ ! -f "$CLAUDE_CONF" ]; then
          echo '{"hasCompletedOnboarding": true}' > "$CLAUDE_CONF"
          chmod 600 "$CLAUDE_CONF"
        fi
      '';
    })
    (lib.mkIf (cfg.enable && deploySecrets) {
      sops.secrets.zhipu = {
        sopsFile = ./claude.secrets.yaml;
      };

      sops.templates."claude-config.json" = {
        path = "${config.home.homeDirectory}/.claude/settings.json";
        content = ''
          {
            "env": {
              "ANTHROPIC_AUTH_TOKEN": "${config.sops.placeholder.zhipu}",
              "ANTHROPIC_BASE_URL": "https://open.bigmodel.cn/api/anthropic",
              "API_TIMEOUT_MS": "3000000",
              "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": 1
            }
          }
        '';
      };
    })
  ];
}

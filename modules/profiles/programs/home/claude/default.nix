{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  deploySecrets = lib.attrByPath [
    "machine"
    "secrets"
    "deploy"
  ] true osConfig;
in
{
  config = lib.mkIf deploySecrets {
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

    programs.claude-code = {
      enable = false; # todo: make it a config
      settings = {
        #  env = {
        #    ANTHROPIC_AUTH_TOKEN = "${config.sops.placeholder.zhipu.path}";

        #    ANTHROPIC_BASE_URL = "https://open.bigmodel.cn/api/anthropic";
        #    API_TIMEOUT_MS = "3000000";
        #    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1;
        #  };
      };
    };

    home.activation.initClaudeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      CLAUDE_CONF="${config.home.homeDirectory}/.claude.json"

      # 检查文件是否存在
      if [ ! -f "$CLAUDE_CONF" ]; then
        # 如果不存在，创建文件并写入初始化配置
        echo '{"hasCompletedOnboarding": true}' > "$CLAUDE_CONF"
        # 确保文件权限是当前用户可读写 (644 或 600)
        chmod 600 "$CLAUDE_CONF"
      fi
    '';
  };
}

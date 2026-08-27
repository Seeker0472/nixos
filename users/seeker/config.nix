{ lib, ... }:
{
  programs = {
    bash.enable = true;
    # Keep Codex's mutable config.toml local; HM manages the selected profile.
    # Hosts can opt out with `programs.codex.enable = false`.
    codex = {
      enable = lib.mkDefault true;
      profiles.nix = lib.mkDefault {
        model_provider = "OpenAI";
        model = "gpt-5.6-sol";
        review_model = "gpt-5.6-sol";
        model_reasoning_effort = "xhigh";
        approvals_reviewer = "auto_review";
        sandbox_mode = "workspace-write";
        service_tier = "fast";
        cli_auth_credentials_store = "file";
        check_for_update_on_startup = false;

        sandbox_workspace_write.network_access = true;

        model_providers.OpenAI = {
          name = "OpenAI";
          base_url = "https://rust.cat";
          wire_api = "responses";
          requires_openai_auth = true;
          supports_websockets = false;
        };

        features.goals = true;
      };
    };
    direnv.enable = true;
    fish.enable = true;
    tmux.enable = true;
    yazi.enable = true;
    zellij.enable = true;
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  codexConfigPath = "${config.home.homeDirectory}/.codex/config.toml";
  managedCodexConfig =
    (pkgs.formats.toml { }).generate "codex-managed-config.toml"
      config.programs.codex.settings;
in
{
  programs = {
    bash.enable = true;
    # Keep Codex's config.toml mutable so it can persist project trust.
    # Hosts can opt out with `programs.codex.enable = false`.
    codex = {
      enable = lib.mkDefault true;
      settings = lib.mkDefault {
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

  # The upstream module normally links config.toml into the read-only Nix
  # store. Materialize it below instead, preserving Codex-owned state.
  home.file.".codex/config.toml".enable = lib.mkIf config.programs.codex.enable (lib.mkForce false);

  home.activation.mergeCodexConfig = lib.mkIf config.programs.codex.enable (
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      codex_config=${lib.escapeShellArg codexConfigPath}
      codex_config_dir="''${codex_config%/*}"

      run ${pkgs.coreutils}/bin/mkdir -p "$codex_config_dir"
      if [[ -v DRY_RUN ]]; then
        echo "Would merge managed Codex settings into $codex_config"
      else
        umask 077
        codex_config_tmp="$(${pkgs.coreutils}/bin/mktemp "$codex_config_dir/.config.toml.home-manager.XXXXXX")"

        if [[ -e "$codex_config" || -L "$codex_config" ]]; then
          if [[ ! -r "$codex_config" ]]; then
            echo "Cannot read existing Codex config: $codex_config" >&2
            ${pkgs.coreutils}/bin/rm -f "$codex_config_tmp"
            exit 1
          fi
          if ! ${lib.getExe pkgs.yq-go} eval-all \
            --input-format toml \
            --output-format toml \
            'select(fileIndex == 0) * select(fileIndex == 1)' \
            "$codex_config" ${managedCodexConfig} > "$codex_config_tmp"; then
            ${pkgs.coreutils}/bin/rm -f "$codex_config_tmp"
            exit 1
          fi
        else
          ${pkgs.coreutils}/bin/cp ${managedCodexConfig} "$codex_config_tmp"
        fi

        ${pkgs.coreutils}/bin/chmod 0600 "$codex_config_tmp"
        if [[ ! -L "$codex_config" ]] && ${pkgs.diffutils}/bin/cmp -s "$codex_config_tmp" "$codex_config"; then
          ${pkgs.coreutils}/bin/chmod 0600 "$codex_config"
          ${pkgs.coreutils}/bin/rm -f "$codex_config_tmp"
        else
          ${pkgs.coreutils}/bin/mv -fT "$codex_config_tmp" "$codex_config"
        fi
      fi
    ''
  );
}

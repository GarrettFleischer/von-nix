{
  config,
  ...
}:

{
  programs.hermes-agent.enable = true;

  services.hermes-agent = {
    enable = true;

    settings = {
      # Model
      model.default = "upstage/solar-pro4:free";
      model.provider = "nous";
      model.base_url = "https://inference-api.nousresearch.com/v1";
      model.api_mode = "chat_completions";

      # Terminal
      terminal.backend = "local";
      terminal.cwd = "/home/von";
      terminal.timeout = 180;

      # Toolsets
      toolsets = [ "all" ];

      # Agent
      agent.reasoning_effort = "medium";
    };

    # Keep API keys out of the Nix store. setup-hermes.sh writes this file.
    environmentFiles = [ "${config.home.homeDirectory}/.config/hermes/env" ];

    gateway.enable = true;
  };
}

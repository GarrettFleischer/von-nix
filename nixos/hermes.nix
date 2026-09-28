{
  config,
  ...
}:

{
  programs.hermes-agent.enable = true;

  services.hermes-agent = {
    enable = true;

    settings = {
      model.default = "anthropic/claude-sonnet-4";
      toolsets = [ "all" ];
      terminal = {
        backend = "local";
        timeout = 180;
      };
    };

    # Keep API keys out of the Nix store. setup-hermes.sh writes this file.
    environmentFiles = [ "${config.home.homeDirectory}/.config/hermes/env" ];

    gateway.enable = true;
  };
}

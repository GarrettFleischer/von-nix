{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Add the cursor flake here
    cursor-flake.url = "github:TudorAndrei/cursor-nixos-flake";
  };

  outputs = { self, nixpkgs, cursor-flake, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # Adjust if you are on aarch64-linux
      specialArgs = { inherit inputs; }; # This passes inputs to configuration.nix
      modules = [ ./configuration.nix ];
    };
  };
}

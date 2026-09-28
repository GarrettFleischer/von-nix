{
  description = "NixOS + Niri + Noctalia + Home Manager";

  # Trusted when this flake is evaluated. The same substituters are set in
  # configuration.nix so later system rebuilds can use them too.
  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pin the cachix branch and do not follow nixpkgs. Following nixpkgs
    # changes the derivation hash and misses Noctalia's binary cache.
    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    # Zen browser (Firefox fork; prebuilt tarball, not in nixpkgs)
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs =
    { self, nixpkgs, home-manager, noctalia, ... }@inputs:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          noctalia.nixosModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.von = import ./home.nix;
          }
        ];
      };
    };
}

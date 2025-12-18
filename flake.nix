{
  description = "Home Manager and NixOS configuration of simon";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    username = "simon";
  in {
    nixosConfigurations.e495 = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs username; };
      modules = [
        ./hosts/e495/configuration.nix
        ./nixosModules
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs username; };
          home-manager.users.${username} = {
            imports = [
              ./home.nix
              ./modules/home-manager
            ];
          };
        }
      ];
    };

    homeManagerModules.default = ./modules/home-manager;

    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        ./home.nix
        ./modules/home-manager
      ];
    };
  };
}

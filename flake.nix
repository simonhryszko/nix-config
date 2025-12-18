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
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs username; };
          home-manager.users.${username} = {
            imports = [
              ./home.nix
              ./modules/home-manager/default.nix
            ];
          };
        }
      ];
    };

    nixosModules = {
      sway = import ./modules/nixos/sway.nix;
      audio = import ./modules/nixos/audio.nix;
      bluetooth = import ./modules/nixos/bluetooth.nix;
      steam = import ./modules/nixos/steam.nix;
      power-management = import ./modules/nixos/power-management.nix;
      display-manager = import ./modules/nixos/display-manager.nix;
    };
    homeManagerModules = {
      sway = import ./modules/home-manager/sway.nix;
      common = import ./modules/home-manager/common.nix;
      development = import ./modules/home-manager/development.nix;
      desktop = import ./modules/home-manager/desktop.nix;
      steam = import ./modules/home-manager/steam.nix;
      minecraft = import ./modules/home-manager/minecraft.nix;
    };
  };
}

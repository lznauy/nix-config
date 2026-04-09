{
  description = "lznauy's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    claude-code.url = "github:sadjow/claude-code-nix";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { 
    self, nixpkgs, home-manager, 
    nix4nvchad, claude-code, noctalia, ... 
  }@inputs:
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {

      modules = [
        ({ ... }: {
          nixpkgs.hostPlatform = "x86_64-linux";
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [
            claude-code.overlays.default
          ];
        })
        ./hosts/default/hardware.nix
        ./hosts/default/default.nix

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.sharedModules = [
            inputs.nix4nvchad.homeManagerModules.default
            inputs.noctalia.homeModules.default
          ];

          home-manager.users.lznauy = import ./home/default.nix;
        }
      ];

      specialArgs = { inherit inputs; };
    };
  };
}

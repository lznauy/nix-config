{
  description = "lznauy's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    claude-code.url = "github:sadjow/claude-code-nix";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quien = {
      url = "github:retlehs/quien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixvim,
      noctalia,
      claude-code,
      agenix,
      quien,
      stylix,
      ...
    }@inputs:
    let
      commonModules = [
        agenix.nixosModules.default
        (
          { ... }:
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              claude-code.overlays.default
              inputs.nur.overlays.default
              (final: prev: {
                # vendorHash 与上游不匹配，手动覆盖
                quien = quien.packages.${prev.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
                  vendorHash = "sha256-aErscLglpLDXH5jxEt6KFDlBH2JjtXDcX4J3YrL5ouI=";
                });
                wayscrollshot = final.callPackage ./pkgs/wayscrollshot.nix { };
                # 测试环境有问题，跳过
                pipx = prev.pipx.overridePythonAttrs { doCheck = false; };
                # 锁定 QQNT 版本，使用腾讯 CDN 下载
                qq = prev.qq.overrideAttrs (old: {
                  version = "3.2.29-2026-05-28";
                  src = prev.fetchurl {
                    url = "https://qqdl.gtimg.cn/qqfile/QQNT/9.9.31/release/00e6a3e7/QQ_3.2.29_260528_amd64_01.deb";
                    hash = "sha256-HjgoB5ZzyUmUvA9HgNXYUoZHY5kgZZhi1J0cLyoZjiU=";
                  };
                });
              })
            ];
          }
        )
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.sharedModules = [
            inputs.nixvim.homeModules.nixvim
            inputs.noctalia.homeModules.default
            inputs.stylix.homeModules.stylix
          ];

          home-manager.users.lznauy = import ./home/default.nix;
        }
      ];

      mkHost = hostModules: nixpkgs.lib.nixosSystem {
        modules = commonModules ++ hostModules;
        specialArgs = { inherit inputs; };
      };
    in
    {
      # VMware 桌面机
      nixosConfigurations.nixos = mkHost [
        ./hosts/vmware/hardware.nix
        ./hosts/vmware/default.nix
      ];

      # 物理机
      nixosConfigurations.physical = mkHost [
        ./hosts/physical/hardware.nix
        ./hosts/physical/default.nix
      ];

      devShells.x86_64-linux = import ./home/programs/devshell/default.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; };

    }
    // (import ./hosts/virtual/default.nix { inherit nixpkgs; });
}

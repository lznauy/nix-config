{
  description = "lznauy's NixOS";

  nixConfig = {
    extra-substituters = [
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

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
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quien.url = "github:retlehs/quien";

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    witr.url = "github:pranshuparmar/witr";

    mark-shot.url = "github:jswysnemc/mark-shot";

    open-design = {
      url = "github:nexu-io/open-design";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
      sops-nix,
      quien,
      stylix,
      witr,
      mark-shot,
      ...
    }@inputs:
    let
      commonModules = [
        sops-nix.nixosModules.sops
        (
          { ... }:
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            nixpkgs.config.allowUnfree = true;
            nix.settings = {
              extra-substituters = [
                "https://cache.numtide.com"
                "https://noctalia.cachix.org"
              ];
              extra-trusted-public-keys = [
                "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
                "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
              ];
            };
            nixpkgs.overlays = [
              claude-code.overlays.default
              inputs.nur.overlays.default
              (final: prev: {
                quien = quien.packages.${prev.stdenv.hostPlatform.system}.default;
                witr = witr.packages.${prev.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
                  # launchd 测试是 macOS 专属，proc 文件锁测试在沙盒中失败
                  doCheck = false;
                });
                mark-shot = mark-shot.packages.${prev.stdenv.hostPlatform.system}.default;
                # 测试环境有问题，跳过
                pipx = prev.pipx.overridePythonAttrs { doCheck = false; };
                niri = prev.niri.overrideAttrs (old: {
                  patches = (old.patches or [ ]) ++ [
                    (prev.fetchpatch {
                      name = "niri-shm-sharing-26.04.patch";
                      url = "https://github.com/wrvsrx/niri/compare/tag_support-shm-sharing_4~19..tag_support-shm-sharing_4.patch";
                      sha256 = "15czbxdvcmm7fp4w3d1n463kpg7l6mbjh1msm6176296nn7g7dic";
                    })
                  ];
                });
                # QQNT — 版本锁定
                qq = final.callPackage ./home/programs/qq/package.nix { qq = prev.qq; };
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
            inputs.open-design.homeManagerModules.default
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
      nixosConfigurations =
        {
          # VMware 桌面机
          nixos = mkHost [
            ./hosts/vmware/hardware.nix
            ./hosts/vmware/default.nix
          ];

          # 物理机
          physical = mkHost [
            ./hosts/physical/hardware.nix
            ./hosts/physical/default.nix
          ];
        }
        // (import ./hosts/virtual/default.nix { inherit nixpkgs; });

      devShells.x86_64-linux = import ./home/programs/devshell/default.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; };

    };
}

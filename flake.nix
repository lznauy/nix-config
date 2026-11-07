{
  description = "lznauy's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # 仅供独立工具和预编译包运行依赖追新，系统基座保持 nixos-26.05。
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-flatpak.url = "git+https://github.com/gmodena/nix-flatpak?ref=refs/tags/v0.7.0";

    # 单包固定到已验证有官方缓存的快照，避免依赖其他应用的间接输入。
    nixpkgs-cached.url = "https://releases.nixos.org/nixos/unstable/nixos-26.11pre1105037.1c89083e451e/nixexprs.tar.zst";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:nix-community/nixvim/nixos-26.05";

    noctalia.url = "github:noctalia-dev/noctalia-shell";

    sops-nix = {
      url = "github:Mic92/sops-nix";
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

    llm-agents.url = "github:numtide/llm-agents.nix";

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      mkHost =
        hostModules:
        nixpkgs.lib.nixosSystem {
          modules = [ { nixpkgs.hostPlatform = system; } ] ++ hostModules;
          specialArgs = { inherit inputs; };
        };
    in
    {
      nixosConfigurations = {
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

      devShells.${system} = import ./home/programs/devshell { inherit pkgs; };
      formatter.${system} = pkgs.nixfmt-tree;
      checks.${system} = (import ./checks { inherit pkgs inputs; }) // {
        # 预编译包的桌面入口及 ABI 安装检查也必须进入常规 just check。
        inherit (inputs.self.nixosConfigurations.physical.pkgs) mark-shot quien splayer-next;
      };
    };
}

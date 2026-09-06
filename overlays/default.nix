{ inputs }:
final: prev:
let
  system = prev.stdenv.hostPlatform.system;
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
  inherit (inputs)
    quien
    witr
    mark-shot
    tailcat
    surge
    ;
in
{
  # 稳定分支基座，clash-verge-rev 单包追 nixpkgs-unstable（上游正式版，非 AutoBuild）
  inherit (unstablePkgs) clash-verge-rev;

  quien = quien.packages.${system}.default;
  witr = witr.packages.${system}.default.overrideAttrs {
    # launchd 测试是 macOS 专属，proc 文件锁测试在沙盒中失败
    doCheck = false;
  };
  mark-shot = mark-shot.packages.${system}.default;
  # e2e 测试需网络且并行 exec 构建产物，Nix 沙箱下必然失败，跳过
  tailcat = tailcat.packages.${system}.default.overrideAttrs {
    doCheck = false;
  };
  # 上游 flake 的 vendorHash 已过期，修正为当前 go.mod 的实际值。
  surge = surge.packages.${system}.default.overrideAttrs {
    vendorHash = "sha256-Ei2i7dQ9s42Gg6f2iLABbTG7OQspjHoRnqIhkfcNvFo=";
  };
  # 测试环境有问题，跳过
  pipx = prev.pipx.overridePythonAttrs { doCheck = false; };
  niri = prev.niri.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (prev.fetchpatch {
        name = "niri-shm-sharing-26.04.patch";
        url = "https://github.com/wrvsrx/niri/compare/tag_support-shm-sharing_4~19..tag_support-shm-sharing_4.patch";
        sha256 = "15czbxdvcmm7fp4w3d1n463kpg7l6mbjh1msm6176296nn7g7dic";
      })
      # 修复 DMA-BUF modifier 协商及 SHM buffer metadata；上游 fork PR #1。
      (prev.fetchpatch {
        name = "niri-shm-sharing-26.04-fixes.patch";
        url = "https://github.com/wrvsrx/niri/compare/6c1613cee488515f3021ae9d8ef9233d6719c13f...2ab59b9.patch";
        sha256 = "sha256-tmy24IzDnx7hJfQs/Ufy8qXDA8L0b/uTilRRxHcIBMM=";
      })
    ];
  });
  # QQNT — 版本锁定
  qq = final.callPackage ../pkgs/qq { inherit (prev) qq; };
}

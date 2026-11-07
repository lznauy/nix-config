{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  qt6,
  kdePackages,
  libglvnd,
  libxcb,
  libpulseaudio,
  wayland,
  pipewire,
  ffmpeg,
  zxing-cpp,
  stdenv,
  grim,
  wl-clipboard,
  python3,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mark-shot";
  version = "0.1.62";
  src = fetchurl {
    url = "https://github.com/jswysnemc/mark-shot/releases/download/v${finalAttrs.version}/mark-shot-v${finalAttrs.version}-linux-x86_64.tar.gz";
    hash = "sha256-POsX43OgIPAQJ2UjHjMUL/AJUT/G4V/yfugRHUA/ZQU=";
  };
  sourceRoot = ".";
  nativeBuildInputs = [
    autoPatchelfHook
    qt6.wrapQtAppsHook
  ];
  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
    kdePackages.layer-shell-qt
    libglvnd
    libxcb
    libpulseaudio
    wayland
    pipewire
    ffmpeg
    zxing-cpp
    stdenv.cc.cc.lib
  ];
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r bin lib share $out/
    for desktop in $out/share/applications/*.desktop; do
      substituteInPlace "$desktop" --replace-fail /usr/bin/mark-shot "$out/bin/mark-shot"
    done
    # 官方 RapidOCR 插件要求 ONNX Runtime 1.29，当前 nixpkgs 只有 1.27。
    # 原源码 flake 也未提供该可选插件；保留原有外部 OCR 脚本回退。
    rm $out/lib/mark-shot/plugins/libmark-shot-ocr-rapid.so
    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_STYLE_OVERRIDE=Fusion
    export XDG_CACHE_HOME="$TMPDIR/cache" XDG_CONFIG_HOME="$TMPDIR/config"
    $out/bin/mark-shot --version
    # 菜单和“打开方式”必须指向实际存在的可执行文件，而不是发行版 /usr/bin。
    for desktop in $out/share/applications/*.desktop; do
      while IFS='=' read -r key value; do
        if [ "$key" = Exec ]; then
          executable="''${value%% *}"
          test -x "$executable" || {
            echo "Invalid desktop executable in $desktop: $executable" >&2
            exit 1
          }
        fi
      done < "$desktop"
    done
    # 用应用自己的 glibc loader 校验全部插件的依赖和符号版本。
    for plugin in $out/lib/mark-shot/*.so $out/lib/mark-shot/*/*.so; do
      linkage=$(LD_TRACE_LOADED_OBJECTS=1 LD_WARN=1 LD_BIND_NOW=1 \
        ${stdenv.cc.bintools.dynamicLinker} "$plugin" 2>&1)
      if printf '%s\n' "$linkage" | grep -E 'not found|undefined symbol:'; then
        echo "Plugin ABI check failed: $plugin" >&2
        exit 1
      fi
    done
    runHook postInstallCheck
  '';
  qtWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        grim
        wl-clipboard
        python3
      ]
    }"
    "--prefix QT_PLUGIN_PATH : ${kdePackages.layer-shell-qt}/${qt6.qtbase.qtPluginPrefix}"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ kdePackages.layer-shell-qt ]}"
  ];
  meta = {
    description = "Qt screenshot and annotation tool (official release binary)";
    homepage = "https://github.com/jswysnemc/mark-shot";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "mark-shot";
  };
})

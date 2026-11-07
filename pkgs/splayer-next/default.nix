{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeWrapper,
  desktop-file-utils,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libpulseaudio,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nss,
  nspr,
  pango,
  pipewire,
  systemd,
}:
let
  audioMimeTypes = [
    "audio/mpeg"
    "audio/flac"
    "audio/x-flac"
    "audio/ogg"
    "audio/opus"
    "audio/x-opus+ogg"
    "audio/x-vorbis+ogg"
    "audio/wav"
    "audio/x-wav"
    "audio/aac"
    "audio/mp4"
    "audio/x-m4a"
    "audio/x-aiff"
    "audio/x-ms-wma"
    "audio/x-ape"
    "audio/x-wavpack"
    "audio/x-musepack"
  ];
  desktopId = "top.imsyy.splayer_next.desktop";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "splayer-next";
  version = "1.2.0";
  src = fetchurl {
    url = "https://github.com/SPlayer-Dev/SPlayer-Next/releases/download/v${finalAttrs.version}/splayer-next-${finalAttrs.version}-amd64.deb";
    hash = "sha256-7dgjIBhIIMi3Y9QM4I2idxr2U7ePZlW1sICLcYsxXbw=";
  };
  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
    makeWrapper
    desktop-file-utils
  ];
  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libglvnd
    libnotify
    libpulseaudio
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nss
    nspr
    pango
    pipewire
    systemd
    stdenv.cc.cc.lib
  ];
  runtimeDependencies = map lib.getLib [
    libglvnd
    libnotify
    libpulseaudio
  ];
  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';
  dontConfigure = true;
  dontBuild = true;
  dontWrapGApps = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec $out/bin $out/share/applications
    cp -r opt/SPlayer-Next $out/libexec/
    # 上游据此决定是否调用 DEB 更新器；Nix 安装只允许通过 Nix 更新。
    printf 'nix\n' > $out/libexec/SPlayer-Next/resources/package-type
    cp -r usr/share/icons $out/share/
    cp usr/share/applications/*.desktop $out/share/applications/${desktopId}
    substituteInPlace $out/share/applications/${desktopId} \
      --replace-fail /opt/SPlayer-Next/SPlayer-Next "$out/bin/SPlayer-Next" \
      --replace-fail 'MimeType=x-scheme-handler/orpheus;' \
        'MimeType=${lib.concatStringsSep ";" (audioMimeTypes ++ [ "x-scheme-handler/orpheus" ])};'
    runHook postInstall
  '';
  postFixup = ''
    makeWrapper $out/libexec/SPlayer-Next/SPlayer-Next $out/bin/SPlayer-Next \
      --unset APPIMAGE \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      "''${gappsWrapperArgs[@]}"
    # 保留旧命令名，已有快捷方式仍可启动新版。
    ln -s SPlayer-Next $out/bin/splayer
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    desktop-file-validate $out/share/applications/${desktopId}
    grep -F "Exec=$out/bin/SPlayer-Next %U" $out/share/applications/${desktopId}
    ELECTRON_RUN_AS_NODE=1 $out/libexec/SPlayer-Next/SPlayer-Next -e '
      const assert = require("node:assert/strict");
      assert.equal(process.versions.electron, "44.9.0");
      const root = process.argv[1];
      assert.equal(require("node:fs").readFileSync(root + "/resources/package-type", "utf8").trim(), "nix");
      for (const name of ["audio-engine", "audio-capture", "media-ctrl", "opencc"]) {
        require(root + "/resources/native/" + name + ".node");
      }
      require(root + "/resources/app.asar.unpacked/node_modules/better-sqlite3/prebuilds/linux-x64.node");
      console.log("Electron " + process.versions.electron + ": all native modules loaded");
    ' $out/libexec/SPlayer-Next
    ${lib.getExe' dbus "dbus-run-session"} --config-file=${dbus}/share/dbus-1/session.conf \
      -- env ELECTRON_RUN_AS_NODE=1 \
      $out/libexec/SPlayer-Next/SPlayer-Next ${./check-mpris.cjs} \
      $out/libexec/SPlayer-Next ${lib.getExe' systemd "busctl"}
    runHook postInstallCheck
  '';
  passthru = { inherit audioMimeTypes desktopId; };
  meta = {
    description = "Music player with lyrics and streaming support (official release binary)";
    homepage = "https://github.com/SPlayer-Dev/SPlayer-Next";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "SPlayer-Next";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})

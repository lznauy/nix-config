{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "quien";
  version = "0.12.0";
  src = fetchurl {
    url = "https://github.com/retlehs/quien/releases/download/v${finalAttrs.version}/quien_linux_amd64.tar.gz";
    hash = "sha256-Kq5C6GEDdO5X5Hk5vmW/fhbxRhRaQCcI5/G12yaP7YM=";
  };
  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 quien $out/bin/quien
    install -Dm644 LICENSE.md $out/share/licenses/quien/LICENSE.md
    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/quien --version
    runHook postInstallCheck
  '';
  meta = {
    description = "WHOIS and domain intelligence toolkit";
    homepage = "https://github.com/retlehs/quien";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "quien";
  };
})

{
  importNpmLock,
  nodejs,
  writeShellApplication,
  coreutils,
  pnpm,
}:
let
  modules = importNpmLock.buildNodeModules {
    npmRoot = ./.;
    inherit nodejs;
    derivationArgs = {
      pname = "dsh-node-modules";
      version = "0.1.0-rc.6";
    };
  };
in
writeShellApplication {
  name = "dsh";
  runtimeInputs = [
    coreutils
    nodejs
    pnpm
  ];
  text = ''
    exec node --expose-internals ${modules}/node_modules/@deepseek-ai/dsh/lib/bin.js "$@"
  '';
}

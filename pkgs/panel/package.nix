{
  lib,
  stdenv,
  nodejs,
  pnpmConfigHook,
  pnpm,
  fetchPnpmDeps,
  fetchFromGitHub,
  rustPlatform,
  perl,
  openssl,
  pkg-config,
  aws-lc,
  sqlite,
  zstd,
}: let
  version = "1.2.11";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "panel";
    rev = "release-${version}";
    sha256 = "sha256-r4JGdEpyXttUD7ga5bq75/zG7PKCuLD7oIa1agdiNSM=";
  };
  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "calagopus-panel-frontend";
    inherit version;

    src = src + "/frontend";

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 4;
      hash = "sha256-AQUb2aZnzeblNsqVVwH3wY4+LIw5tqY259A8U+B1Wcc=";
    };

    buildPhase = ''
      runHook preBuild
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      cp -r dist/ $out
    '';
  });
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "calagopus-panel";
    inherit version src;

    cargoHash = "sha256-H77b/6CxK33cUCy4tQ+8qSBD021CzhHpE9aPLJPkTu4=";
    cargoBuildFlags = ["-p" "panel-rs"];
    cargoTestFlags = ["-p" "panel-rs"];

    nativeBuildInputs = [
      perl
      openssl
      pkg-config
    ];

    # cargoSetupHook makes the -sys crates link these instead of vendoring
    buildInputs = [
      aws-lc
      sqlite
      zstd
    ];
    env = {
      CARGO_GIT_BRANCH = "unknown";
      CARGO_GIT_COMMIT = "unknown";
    };

    preBuild = ''
      # Copy the frontend source code to the build directory
      cp -r ${frontend} ./frontend/dist/
    '';

    passthru = {
      inherit frontend;
    };

    meta = {
      description = "Game server management - made simple";
      homepage = "https://calagopus.com/";
      license = lib.licenses.mit;
      maintainers = [];
      mainProgram = "panel-rs";
    };
  })

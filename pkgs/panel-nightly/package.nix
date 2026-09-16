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
}: let
  version = "db41b24f115eee3f7e013548efe2b4c41a0e7996";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "panel";
    rev = "${version}";
    sha256 = "sha256-psXiko3yo7rTnaRv9YxWiwobB+Ai3cO6jsZrbj8MI9M=";
  };
  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "calagopus-panel-nightly-frontend";
    version = "v${version}";

    src = src + "/frontend";

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 4;
      hash = "sha256-QUQW/pD9C7B9/FEd4eLrfPROtDjwtPM6Ty7/Q/+hwP4=";
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
    pname = "calagopus-panel-nightly";
    version = "v${version}";
    inherit src;

    cargoHash = "sha256-JHL0itWgyzf7ydiCLGo3PTPuzRFctTCTBblh0QjPSEY=";
    cargoBuildFlags = ["-p" "panel-rs"];
    cargoTestFlags = ["-p" "panel-rs"];

    nativeBuildInputs = [
      perl
      openssl
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

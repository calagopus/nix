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
  version = "3c00b1e49212aa35e0ee3f22250b3f2b3bd3af4c";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "panel";
    rev = "${version}";
    sha256 = "sha256-U+xLUA5hb5Hsk8gfz1uW0An0LbW3SMGFYsWtlfN2H3A=";
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
      hash = "sha256-LhFiaiharPUIuSYIM/BCvlDUDhh+aEnzXtviBqEY8Ks=";
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

    cargoHash = "sha256-0MLRnmlt/W0z6VveAWI0H76LLUERrfTKsY8kBj09Y6o=";
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

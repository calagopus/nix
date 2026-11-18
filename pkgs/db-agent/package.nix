{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cacert,
  cmake,
  perl,
  aws-lc,
  sqlite,
  pkg-config,
}: let
  version = "1.2.4";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "db-agent";
    rev = "release-${version}";
    hash = "sha256-TouLiXPRyCdT9c+1e88l7myqBFeKsYzcaJzj+q83XR0=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "calagopus-db-agent";
    inherit version src;

    cargoHash = "sha256-VeeuZwd3LzizauYcBUgg4xH1919NfcEcyu6ERrSjpx4=";

    # zlib-ng is built from source
    nativeBuildInputs = [
      cmake
      perl
      pkg-config
    ];

    # cargoSetupHook makes the -sys crates link these instead of vendoring
    buildInputs = [
      aws-lc
      sqlite
    ];

    # The upgrade tests build a reqwest client, which needs CA certificates
    nativeCheckInputs = [cacert];

    env = {
      CARGO_GIT_BRANCH = "unknown";
      CARGO_GIT_COMMIT = "unknown";
    };

    meta = {
      description = "High-performance database proxy and provisioning agent for PostgreSQL, MySQL, Redis and MongoDB";
      homepage = "https://calagopus.com";
      license = lib.licenses.mit;
      maintainers = [];
      mainProgram = "db-agent";
      platforms = lib.platforms.linux;
    };
  })

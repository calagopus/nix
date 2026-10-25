{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cacert,
  cmake,
  perl,
}: let
  rev = "3b276ef3eb9f825256b60356f52a8f55140dc776";
  version = "release-1.2.4-unstable-2026-10-23";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "db-agent";
    inherit rev;
    hash = "sha256-TouLiXPRyCdT9c+1e88l7myqBFeKsYzcaJzj+q83XR0=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "calagopus-db-agent-nightly";
    inherit version src;

    cargoHash = "sha256-VeeuZwd3LzizauYcBUgg4xH1919NfcEcyu6ERrSjpx4=";

    # aws-lc-sys and zlib-ng are built from source
    nativeBuildInputs = [
      cmake
      perl
    ];

    # The upgrade tests build a reqwest client, which needs CA certificates
    nativeCheckInputs = [cacert];

    env = {
      CARGO_GIT_BRANCH = "main";
      CARGO_GIT_COMMIT = rev;
    };

    meta = {
      description = "High-performance database proxy and provisioning agent for PostgreSQL, MySQL, Redis and MongoDB (nightly build)";
      homepage = "https://calagopus.com";
      license = lib.licenses.mit;
      maintainers = [];
      mainProgram = "db-agent";
      platforms = lib.platforms.linux;
    };
  })

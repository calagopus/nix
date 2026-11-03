{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cacert,
  cmake,
  perl,
}: let
  rev = "c0223fd6b673c835650769f0f57ebbda1d7127c3";
  version = "release-1.2.4-unstable-2026-11-03";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "db-agent";
    inherit rev;
    hash = "sha256-X+SJtmffNCOsxEqDPnGxIJD44ntJYTuLV64VTrH+e9k=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "calagopus-db-agent-nightly";
    inherit version src;

    cargoHash = "sha256-WzY3hl+FH3yD+2KbvASJjdc/zb2TDfF45Rxy1cSDjwE=";

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

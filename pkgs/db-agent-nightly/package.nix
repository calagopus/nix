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
  rust-jemalloc-sys,
}: let
  rev = "3214051164cf6f37ae5eca28f8c25ac234a1e1d1";
  version = "release-1.2.4-unstable-2026-11-21";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "db-agent";
    inherit rev;
    hash = "sha256-6gcmXTGeZtFgEc+Xjg9LY64ZmsRvpMls+N37bOOujak=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "calagopus-db-agent-nightly";
    inherit version src;

    cargoHash = "sha256-Yc3+Jnjv/jVlcETDrNvfeZhtOk6pNNT07+1yjAiBJmk=";

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
      rust-jemalloc-sys
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

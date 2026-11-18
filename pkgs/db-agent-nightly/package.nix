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
  rev = "6270fb3b8603e9719b2233535d8f9ed2d6730264";
  version = "release-1.2.4-unstable-2026-11-16";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "db-agent";
    inherit rev;
    hash = "sha256-j5vOfbM3Z9jiP72TxYn3oNL2T2jE5VEjEhRo6zrLnx0=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "calagopus-db-agent-nightly";
    inherit version src;

    cargoHash = "sha256-pafKxmxsBIxnr8wj7djhnenbOOhRxb56J+vec4YbHJw=";

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
